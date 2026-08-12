import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/downland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every rope in them was tied by taps, so nothing in the pictures
/// is a down the game could not reach.
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

  Future<void> tieByPointer(WidgetTester tester) async {
    var guard = 0;
    while (!state(tester).play.isDone && guard++ < 16) {
      await press(tester, 'Show me');
      final ((a, b), _) = state(tester).pointing!;
      await tieRope(tester, (a, b));
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the downland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'downland-${phone.key}');
    });

    testWidgets('the nine tethered on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await tieByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nine-${phone.key}');
    });
  }

  testWidgets('the square tethered', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tieAll(tester, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'square');
  });

  testWidgets('a knot called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tieAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    await shoot(tester, 'knot');
  });

  testWidgets('a pick in hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tieAll(tester, const [(0, 2), (0, 3)]);
    await tapPost(tester, 1);
    await shoot(tester, 'picking');
  });

  testWidgets('show me pointing a rope', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seventh rope admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 6; round++) {
      await tieRope(tester, (0, 1));
      await tieRope(tester, (0, 1));
    }
    await shoot(tester, 'seventhrope');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'downland-iphone-14.png',
      'nine-iphone-14.png',
      'square.png',
      'knot.png',
      'picking.png',
      'showme.png',
      'why.png',
      'seventhrope.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
