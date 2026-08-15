import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/kerbland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every slab in them was laid by a tap, so nothing in the pictures is
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

    testWidgets('the ten laid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await layAll(tester, [
        (1, 1), (2, 1), (3, 1),
        (1, 2), (2, 2), (3, 2),
        (1, 3), (2, 3), (3, 3),
        (2, 4),
      ]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ten-${phone.key}');
    });
  }

  testWidgets('the square yard laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await layAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'squareyard');
  });

  testWidgets('the six laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layAll(tester, [(1, 1), (2, 1), (3, 1), (1, 2), (2, 2), (3, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('the eight laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layAll(tester, [(1, 1), (2, 1), (3, 1), (1, 2), (2, 2), (3, 2), (1, 3), (2, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eight');
  });

  testWidgets('a yard mid-laying, a dent in the kerb', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layAll(tester, [(1, 1), (2, 1), (3, 1), (1, 2), (3, 2), (1, 3), (2, 3), (3, 3)]);
    expect(state(tester).play.kerb, 16);
    await shoot(tester, 'midlaying');
  });

  testWidgets('show me ringing a cell', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layAll(tester, [(1, 1), (2, 1)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the five in eight admitted, ten round the box of six',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await layAll(tester, [(1, 1), (2, 1), (3, 1), (1, 2), (2, 2)]);
    for (var dither = 0; dither < 3; dither++) {
      await layAll(tester, [(2, 2), (2, 2)]);
    }
    expect(state(tester).play.moves, 11);
    expect(state(tester).play.kerb, 10);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fiveineight');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ten-iphone-14.png',
      'squareyard.png',
      'six.png',
      'eight.png',
      'midlaying.png',
      'showme.png',
      'why.png',
      'fiveineight.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
