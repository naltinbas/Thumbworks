import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plotland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every plot in them was laid by tapping its three pegs, so nothing in
/// the pictures is a cut the game could not reach.
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

  const dead = <List<(int, int)>>[
    [(0, 0), (1, 0), (0, 1)],
    [(1, 0), (2, 0), (1, 1)],
    [(2, 0), (3, 0), (2, 1)],
    [(0, 1), (1, 1), (0, 2)],
    [(1, 1), (2, 1), (1, 2)],
    [(0, 2), (1, 2), (0, 3)],
  ];

  for (final phone in phones.entries) {
    testWidgets('the field on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'field-${phone.key}');
    });

    testWidgets('the three plots on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await cutByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'three-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    expect(state(tester).play.taps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the two plots cut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the even six cut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'evensix');
  });

  testWidgets('part way through the six plots', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layPlot(tester, const [(0, 0), (1, 0), (0, 1)]);
    await layPlot(tester, const [(1, 0), (2, 0), (1, 1)]);
    await tapPeg(tester, 2, 0);
    expect(state(tester).play.holding.length, 1);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the even three given up, the argument drawn', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final trio in dead) {
      await layPlot(tester, trio);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'noteven');
  });

  testWidgets('the even three given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final trio in dead) {
      await layPlot(tester, trio);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'noteven-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'field-iphone-14.png',
      'three-iphone-14.png',
      'opening.png',
      'two.png',
      'evensix.png',
      'midway.png',
      'showme.png',
      'why.png',
      'noteven.png',
      'noteven-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
