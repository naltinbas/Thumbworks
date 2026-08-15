import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/byland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every coin in them was given by taps, so nothing in the pictures is
/// a deck the game could not reach.
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

    testWidgets('five pirates paid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await payByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'five-${phone.key}');
    });
  }

  testWidgets('two pirates', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Vote');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('three pirates', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await payByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('four pirates', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await payByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('a crew mid-paying, before the vote', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [2, 3]);
    expect(state(tester).play.voted, isFalse);
    await shoot(tester, 'midpay');
  });

  testWidgets('show me ringing a pirate', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the greedy captain overboard', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapPirate(tester, 2);
    await press(tester, 'Vote');
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'overboard');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'five-iphone-14.png',
      'two.png',
      'three.png',
      'four.png',
      'midpay.png',
      'showme.png',
      'why.png',
      'overboard.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
