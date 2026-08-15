import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every flag in them was laid by a tap, so nothing in the pictures is
/// a yard the game could not reach.
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

    testWidgets('the six on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await paveByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'six-${phone.key}');
    });
  }

  testWidgets('the three', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await lay(tester, 0, 0, 0);
    await lay(tester, 1, 1, 0);
    await lay(tester, 2, 0, 1, upright: true);
    await lay(tester, 2, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the ten', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ten');
  });

  testWidgets('the fifteen', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await paveByPointer(tester, most: 80);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fifteen');
  });

  testWidgets('mid-paving, a half held upright', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lay(tester, 0, 0, 0);
    await lay(tester, 1, 1, 0);
    await lay(tester, 3, 3, 0);
    await takeKind(tester, 2);
    await press(tester, 'Turn');
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midpaving');
  });

  testWidgets('show me ringing the place', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await lay(tester, 0, 0, 0);
    await takeKind(tester, 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the whole twos admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lay(tester, 0, 2, 2);
    await lay(tester, 1, 0, 0);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'whole');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'six-iphone-14.png',
      'three.png',
      'ten.png',
      'fifteen.png',
      'midpaving.png',
      'showme.png',
      'why.png',
      'whole.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
