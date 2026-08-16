import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/roadland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every setting in them was dialled by taps, so nothing in the
/// pictures is a setting the game could not reach.
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

    testWidgets('the eighty on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setDials(tester, 40, true);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'eighty-${phone.key}');
    });
  }

  testWidgets('the sixty-five', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setDials(tester, 40, false);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sixtyfive');
  });

  testWidgets('the helpful shortcut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setDials(tester, 20, true);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'helpful');
  });

  testWidgets('the break-even', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setDials(tester, 30, true);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'breakeven');
  });

  testWidgets('midway, a big crowd three ways, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    // Open first: shut, the crowd would land forty hundred on the way.
    await toggle(tester);
    await setDials(tester, 50, true);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setDials(tester, 40, false);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the big crowd helped admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setDials(tester, 32, true);
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.open, isTrue);
    await shoot(tester, 'bigcrowd');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'eighty-iphone-14.png',
      'sixtyfive.png',
      'helpful.png',
      'breakeven.png',
      'midway.png',
      'showme.png',
      'why.png',
      'bigcrowd.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
