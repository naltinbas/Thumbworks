import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every wind in them was tapped, so nothing in the pictures is a
/// row the game could not reach.
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
    testWidgets('the wall on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'wall-${phone.key}');
    });

    testWidgets('the full row wound on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await windTo(tester, 15);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fullrow-${phone.key}');
    });
  }

  testWidgets('the two odds wound', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await windTo(tester, 8);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoodds');
  });

  testWidgets('the four odds wound', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await windTo(tester, 10);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourodds');
  });

  testWidgets('the eight odds wound', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await windTo(tester, 13);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eightodds');
  });

  testWidgets('a wall mid-wind', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await windTo(tester, 6);
    expect(state(tester).play.at, 6);
    await shoot(tester, 'midwind');
  });

  testWidgets('show me naming the way', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three odds admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Stand at row two, holding two odds, one shy either way;
    // dither till the wall admits.
    await windTo(tester, 2);
    for (var dither = 0; dither < 10; dither++) {
      await press(
          tester, dither.isEven ? 'wind down' : 'wind up');
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threeodds');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'wall-iphone-14.png',
      'fullrow-iphone-14.png',
      'twoodds.png',
      'fourodds.png',
      'eightodds.png',
      'midwind.png',
      'showme.png',
      'why.png',
      'threeodds.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
