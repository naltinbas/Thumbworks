import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/partland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every part in them was laid by a tap, so nothing in the pictures is
/// a sundering the game could not reach.
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

    testWidgets('the ten on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await addAll(tester, [4, 3, 2, 1]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ten-${phone.key}');
    });
  }

  testWidgets('the different', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await addAll(tester, [5, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'different');
  });

  testWidgets('the odd four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await addAll(tester, [5, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oddfour');
  });

  testWidgets('the square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await sunderByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'square');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await addAll(tester, [6, 3]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me ringing a size', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await addAll(tester, [5, 1]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd evens admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await addAll(tester, [6, 2, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'oddevens');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ten-iphone-14.png',
      'different.png',
      'oddfour.png',
      'square.png',
      'midway.png',
      'showme.png',
      'why.png',
      'oddevens.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
