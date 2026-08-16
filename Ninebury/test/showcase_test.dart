import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/nineland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every number in them was set by taps on the dials, so nothing in
/// the pictures is a number the game could not reach.
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

    testWidgets('the nine on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await dial(tester, 701);
      await dial(tester, 731);
      await dial(tester, 738);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nine-${phone.key}');
    });
  }

  testWidgets('the square seven', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await dial(tester, 529);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'squareseven');
  });

  testWidgets('the cube eight', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await dial(tester, 512);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'cubeeight');
  });

  testWidgets('the slip', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await dial(tester, 864);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'slip');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await dial(tester, 451);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await dial(tester, 10);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the square five admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await dial(tester, 169);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'squarefive');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'nine-iphone-14.png',
      'squareseven.png',
      'cubeeight.png',
      'slip.png',
      'midway.png',
      'showme.png',
      'why.png',
      'squarefive.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
