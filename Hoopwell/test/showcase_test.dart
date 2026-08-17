import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hoopland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every stone in them was laid by a tap on a hole, so nothing in the
/// pictures is a board the game could not reach.
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
    testWidgets('the hoop on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hoop-${phone.key}');
    });

    testWidgets('the floor on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'floor-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    expect(state(tester).play.taps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the six lit', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('every lamp lit', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'everylamp');
  });

  testWidgets('part way through the other six', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapHole(tester, 0, 3);
    await tapHole(tester, 1, 2);
    expect(state(tester).play.taps, 2);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a hole', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('four alight given up, the walk drawn', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final tap in [(0, 1), (1, 1), (1, 2), (1, 3), (0, 2), (1, 4),
      (1, 5), (0, 3)]) {
      await tapHole(tester, tap.$1, tap.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'underfloor');
  });

  testWidgets('four alight given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final tap in [(0, 1), (1, 1), (1, 2), (1, 3), (0, 2), (1, 4),
      (1, 5), (0, 3)]) {
      await tapHole(tester, tap.$1, tap.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'underfloor-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hoop-iphone-14.png',
      'floor-iphone-14.png',
      'opening.png',
      'six.png',
      'everylamp.png',
      'midway.png',
      'showme.png',
      'why.png',
      'underfloor.png',
      'underfloor-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
