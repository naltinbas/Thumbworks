import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/roostland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every bird in them was moved by a tap on a bird, so nothing in the
/// pictures is a seating the game could not reach.
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
    testWidgets('the wood on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'wood-${phone.key}');
    });

    testWidgets('the hub settled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await settleByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'hub-${phone.key}');
    });
  }

  testWidgets('the hub as it opens, six birds in one hollow', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    expect(state(tester).play.crowds[0].length, 6);
    await shoot(tester, 'crowd');
  });

  testWidgets('the two thickets settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thickets');
  });

  testWidgets('the three pairs settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'pairs');
  });

  testWidgets('the two rings part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapBird(tester, 2);
    expect(state(tester).play.taps, 1);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a bird', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the shared tether given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final bird in [0, 1, 2, 3, 4, 5, 0, 1]) {
      await tapBird(tester, bird);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'overfull');
  });

  testWidgets('the shared tether given up, on the small phone',
      (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final bird in [0, 1, 2, 3, 4, 5, 0, 1]) {
      await tapBird(tester, bird);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'overfull-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'wood-iphone-14.png',
      'hub-iphone-14.png',
      'crowd.png',
      'thickets.png',
      'pairs.png',
      'midway.png',
      'showme.png',
      'why.png',
      'overfull.png',
      'overfull-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
