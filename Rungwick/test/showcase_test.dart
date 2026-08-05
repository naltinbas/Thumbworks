import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rungwick/ladder/climbs.dart';
import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ladder/words.dart';
import 'package:rungwick/ui/app.dart';

import 'support/climb.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every rung in them was climbed the way a player climbs one — tap the letter
/// to change, tap what to change it to — so nothing in the pictures is a word
/// the game would have refused.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  late Ladder four;

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    four = Ladder.of(kFour);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture — and this game is nothing but letters.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    for (final family in const ['Roboto', 'MaterialIcons']) {
      final loader = FontLoader(family);
      for (final file in fonts.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (!name.startsWith(family)) continue;
        if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  });

  Future<void> capture(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(screen),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: ratio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$shots/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  var opened = 0;

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: RungwickApp(
          key: ValueKey(opened++),
          ladder: four,
          opensAt: which,
        ),
      ),
    );
    await tester.pump();
  }

  /// Climbs a few rungs by asking, which is the only way to fill a ladder in a
  /// test without writing the answer down.
  Future<void> climbOn(WidgetTester tester, int rungs) async {
    for (var i = 0; i < rungs; i++) {
      if (state(tester).play.isDone) return;
      final next = state(tester).play.nextRung;
      if (next == null) return;
      await climbTo(tester, next);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the climbs on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'climbs-${phone.key}');
    });

    testWidgets('part way up on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 9);
      await climbOn(tester, 3);
      // A letter picked but not yet changed, so the rack is live.
      await tester.tap(
        find.bySemanticsLabel(RegExp('change the second letter')),
      );
      await tester.pump();
      await capture(tester, 'climbing-${phone.key}');
    });

    testWidgets('a word the list does not have on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await climbOn(tester, 2);
      await change(tester, 0, 'q');
      expect(state(tester).saying, contains('not in the list'));
      await capture(tester, 'refused-${phone.key}');
    });
  }

  testWidgets('a rung that goes nowhere', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await climbTo(tester, 'lake');
    expect(state(tester).play.onShortest, isFalse);
    await capture(tester, 'astray');
  });

  testWidgets('a climb finished without a rung wasted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 9);
    await climbIt(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taken, Climbs.at(9).rungs);
    await capture(tester, 'up');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'climbs-iphone-14.png',
      'climbing-iphone-14.png',
      'refused-iphone-14.png',
      'astray.png',
      'up.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
