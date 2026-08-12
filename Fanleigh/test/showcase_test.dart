import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leigh.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every hurdle in them was laid by taps, so nothing in the
/// pictures is a paddock the game could not reach.
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

  Future<void> layByPointer(WidgetTester tester) async {
    var guard = 0;
    while (!state(tester).play.isDone && guard++ < 12) {
      await press(tester, 'Show me');
      final ((a, b), _) = state(tester).pointing!;
      await layHurdle(tester, (a, b));
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the leigh on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'leigh-${phone.key}');
    });

    testWidgets('the zigzag folded on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'zigzag-${phone.key}');
    });
  }

  testWidgets('the fan folded', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layAll(tester, const [(0, 2), (0, 3), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fan');
  });

  testWidgets('the pentagon folded', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await layAll(tester, const [(0, 2), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'pentagon');
  });

  testWidgets('a crossing called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layAll(tester, const [(0, 2), (1, 3)]);
    await shoot(tester, 'crossing');
  });

  testWidgets('show me pointing a hurdle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the earless admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 6; round++) {
      await layHurdle(tester, (0, 2));
      await layHurdle(tester, (0, 2));
    }
    await shoot(tester, 'earless');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'leigh-iphone-14.png',
      'zigzag-iphone-14.png',
      'fan.png',
      'pentagon.png',
      'crossing.png',
      'showme.png',
      'why.png',
      'earless.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
