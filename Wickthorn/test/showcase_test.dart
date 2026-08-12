import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/village.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every rope in them was strung by taps, so nothing in the pictures
/// is a green the game could not reach.
///
/// Run it with: make shots
const fano = [
  (0, 1, 2), (0, 3, 4), (0, 5, 6), (1, 3, 5),
  (1, 4, 6), (2, 3, 6), (2, 4, 5),
];

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
    testWidgets('the village on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'village-${phone.key}');
    });

    testWidgets('the seven ropes closed on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await stringAll(tester, fano);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'closed-${phone.key}');
    });
  }

  testWidgets('two picked towards a rope', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await stringRope(tester, (0, 1, 2));
    await tapLantern(tester, 3);
    await tapLantern(tester, 4);
    await shoot(tester, 'picking');
  });

  testWidgets('a clash called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await stringRope(tester, (0, 1, 2));
    await stringRope(tester, (0, 1, 3));
    await shoot(tester, 'clash');
  });

  testWidgets('the one way, given ropes dim', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await shoot(tester, 'oneway');
  });

  testWidgets('show me ringing three lanterns', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the six lanterns admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    final triples = [
      for (var a = 0; a < 6; a++)
        for (var b = a + 1; b < 6; b++)
          for (var c = b + 1; c < 6; c++) (a, b, c),
    ];
    for (final rope in triples.take(12)) {
      await stringRope(tester, rope);
    }
    await shoot(tester, 'sixlanterns');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'village-iphone-14.png',
      'closed-iphone-14.png',
      'picking.png',
      'clash.png',
      'oneway.png',
      'showme.png',
      'why.png',
      'sixlanterns.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
