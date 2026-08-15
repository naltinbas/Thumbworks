import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every bishop in them was set by a tap, so nothing in the pictures
/// is a board the game could not reach.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);
    await useRealFonts();
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

  Future<void> show(WidgetTester tester, Size size, {int? which}) =>
      open(tester, which: which, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the four at peace on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setAll(tester, [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'four-${phone.key}');
    });
  }

  testWidgets('the three at peace', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, [(0, 0), (0, 1), (0, 2), (2, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the five at peace', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setAll(tester, [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4), (4, 1), (4, 2), (4, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('the held corner at peace', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setAll(tester, [(0, 1), (0, 2), (0, 3), (3, 1), (3, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'heldcorner');
  });

  testWidgets('a board mid-setting, a clash struck', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setAll(tester, [(0, 0), (1, 1), (0, 3)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midsetting');
  });

  testWidgets('show me ringing a square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setAll(tester, [(0, 0), (0, 1)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seven admitted, the corners clashing',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setAll(tester, [(0, 0), (0, 1), (0, 2), (0, 3), (3, 1), (3, 2), (3, 3)]);
    for (var dither = 0; dither < 3; dither++) {
      await setAll(tester, [(3, 3), (3, 3)]);
    }
    expect(state(tester).play.moves, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'seven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'four-iphone-14.png',
      'three.png',
      'five.png',
      'heldcorner.png',
      'midsetting.png',
      'showme.png',
      'why.png',
      'seven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
