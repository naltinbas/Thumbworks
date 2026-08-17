import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hookland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every box in them was moved by a tap on a row, so nothing in the
/// pictures is a staircase the game could not reach.
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

    testWidgets('ninety on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ninety-${phone.key}');
    });
  }

  testWidgets('seventy', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'seventy');
  });

  testWidgets('fourteen', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourteen');
  });

  testWidgets('the single file', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'single');
  });

  testWidgets('a box in hand, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await tapRow(tester, 2);
    expect(state(tester).play.holding, 2);
    await shoot(tester, 'inhand');
  });

  testWidgets('show me lighting a row', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('against the hooks given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final move in [(1, 0), (0, 1), (1, 3), (0, 3)]) {
      await shift(tester, move.$1, move.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'againsthooks');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ninety-iphone-14.png',
      'seventy.png',
      'fourteen.png',
      'single.png',
      'inhand.png',
      'showme.png',
      'why.png',
      'againsthooks.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
