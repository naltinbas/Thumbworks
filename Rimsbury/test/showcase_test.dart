import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rollland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every roll in them was set up by taps, so nothing in the pictures is
/// a setting the game could not reach.
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

    testWidgets('the twice on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await rollByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twice-${phone.key}');
    });
  }

  testWidgets('the thrice', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setCoins(tester, 2, 1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thrice');
  });

  testWidgets('the half', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await rollByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'half');
  });

  testWidgets('the inside once', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setCoins(tester, 4, 2, inside: true);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'inside');
  });

  testWidgets('a misfit, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setCoins(tester, 3, 4, inside: true);
    expect(state(tester).play.fits, isFalse);
    await shoot(tester, 'misfit');
  });

  testWidgets('show me lighting the side', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the once admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setCoins(tester, 1, 6);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'once');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twice-iphone-14.png',
      'thrice.png',
      'half.png',
      'inside.png',
      'misfit.png',
      'showme.png',
      'why.png',
      'once.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
