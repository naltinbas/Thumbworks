import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wickfell/lamps/levels.dart';
import 'package:wickfell/lamps/solve.dart';
import 'package:wickfell/ui/app.dart';

import 'support/lamps.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every lamp that has gone out in them went out by being pressed, so nothing
/// in the pictures is a board the game could not reach.
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

  Future<void> shoot(WidgetTester tester, String name) async {
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
        child: WickfellApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  /// Makes a few of the presses on the way.
  Future<void> playOn(WidgetTester tester, int presses) async {
    for (var i = 0; i < presses; i++) {
      if (state(tester).play.isDone) return;
      final next = state(tester).play.nextPress;
      if (next == null) return;
      await pressLamp(tester, next);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the boards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'boards-${phone.key}');
    });

    testWidgets('a board part way out on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 8);
      await playOn(tester, 5);
      await shoot(tester, 'pressing-${phone.key}');
    });

    testWidgets('being shown a press on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 9);
      await playOn(tester, 6);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      await shoot(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a press that goes nowhere', (tester) async {
    await show(tester, phones['iphone-14']!, which: 6);
    final wanted =
        Sums(Levels.at(6).grid).answer(Levels.at(6).lit).presses.toSet();
    final wrong = List.generate(Levels.at(6).lamps, (at) => at)
        .firstWhere((at) => !wanted.contains(at));
    await pressLamp(tester, wrong);
    expect(state(tester).saying, isNotNull);
    await shoot(tester, 'astray');
  });

  testWidgets('every lamp out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 6);
    await playOn(tester, 40);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'all-out');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'boards-iphone-14.png',
      'pressing-iphone-14.png',
      'shown-iphone-14.png',
      'astray.png',
      'all-out.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
