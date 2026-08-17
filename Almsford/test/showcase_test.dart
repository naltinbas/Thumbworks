import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/almsland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every measure in them was moved by a tap on a bin, so nothing in the
/// pictures is an arrangement the game could not reach.
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

    testWidgets('the staircase on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await shareByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'staircase-${phone.key}');
    });
  }

  testWidgets('three small heaps', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'heaps');
  });

  testWidgets('the even halves', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'halves');
  });

  testWidgets('the level field', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'level');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await share(tester, 4, 0);
    await share(tester, 4, 1);
    await tapBin(tester, 4);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a bin', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the one heap given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final to in [0, 1, 2, 3]) {
      await share(tester, 4, to);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'oneheap');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'staircase-iphone-14.png',
      'heaps.png',
      'halves.png',
      'level.png',
      'midway.png',
      'showme.png',
      'why.png',
      'oneheap.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
