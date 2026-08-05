import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cairnfall/stones/play.dart';
import 'package:cairnfall/stones/rounds.dart';
import 'package:cairnfall/ui/app.dart';

import 'support/table.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every stone that has come off a cairn in them came off by tapping the
/// cairn and then the number, and the numbers beside them are the ones the
/// other player is using.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture.
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

  Future<void> show(
    WidgetTester tester,
    Size size, {
    int? which,
    bool showWorth = false,
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: CairnfallApp(
          key: ValueKey(opened++),
          opensAt: which,
          showWorth: showWorth,
        ),
      ),
    );
    await tester.pump();
  }

  /// Plays a few moves by the arithmetic, both sides.
  Future<void> playOn(WidgetTester tester, int moves) async {
    for (var i = 0; i < moves; i++) {
      if (state(tester).play.isOver) return;
      if (state(tester).theirs) {
        await letThemMove(tester);
        continue;
      }
      final move = state(tester).play.bestMove(CairnfallApp.worth);
      await takeFrom(tester, move.cairn, move.stones);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the rounds on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await capture(tester, 'rounds-${phone.key}');
    });

    testWidgets('a round under way on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      await playOn(tester, 2);
      await pickCairn(tester, 1);
      await capture(tester, 'playing-${phone.key}');
    });

    testWidgets('the numbers on show on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5, showWorth: true);
      await capture(tester, 'numbers-${phone.key}');
    });
  }

  testWidgets('a move that gives the round away', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0, showWorth: true);
    // One stone off the small cairn, which is not the move that wins.
    await takeFrom(tester, 0, 1);
    expect(state(tester).wrong, 1);
    await capture(tester, 'given-away');
  });

  testWidgets('the last stone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await playOn(tester, 40);
    expect(state(tester).play.isOver, isTrue);
    expect(state(tester).play.won, Who.you);
    await capture(tester, 'the-last-stone');
  });

  testWidgets('the biggest round there is', (tester) async {
    await show(tester, phones['iphone-14']!, which: Rounds.count - 1,
        showWorth: true);
    await capture(tester, 'the-yard');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rounds-iphone-14.png',
      'playing-iphone-14.png',
      'numbers-iphone-14.png',
      'given-away.png',
      'the-last-stone.png',
      'the-yard.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
