import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/titheland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every number in them was wound to by taps, so nothing in the
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

    testWidgets('the friends on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await tallyByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'friends-${phone.key}');
    });
  }

  testWidgets('the perfect', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setNumber(tester, 28);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'perfect');
  });

  testWidgets('the abundant', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tallyByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'abundant');
  });

  testWidgets('the twice over', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setNumber(tester, 120);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twiceover');
  });

  testWidgets('midway, at a hundred, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await setNumber(tester, 100);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a winder', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the power of two admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setNumber(tester, 256);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'poweroftwo');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'friends-iphone-14.png',
      'perfect.png',
      'abundant.png',
      'twiceover.png',
      'midway.png',
      'showme.png',
      'why.png',
      'poweroftwo.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
