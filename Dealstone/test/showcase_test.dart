import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stoneland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every stone in them was tapped, so nothing in the pictures is a
/// hand the game could not reach.
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
    testWidgets('the stone on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'stone-${phone.key}');
    });

    testWidgets('the twelve deals piled on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await dealByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twelvedeals-${phone.key}');
    });
  }

  testWidgets('the stair of six piled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'stairofsix');
  });

  testWidgets('the long six piled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'longsix');
  });

  testWidgets('the middle road piled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'middleroad');
  });

  testWidgets('a hand mid-pile', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapSlot(tester, 0);
    await tapSlot(tester, 0);
    await tapSlot(tester, 1);
    expect(state(tester).play.moves, 3);
    await shoot(tester, 'midpile');
  });

  testWidgets('show me ringing a slot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the eight standstill admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Build the nearest miss, three, two, two, one, a stair
    // with a doubled step; then dither its last stone till the
    // stone admits, the tableau still standing.
    await tapSlot(tester, 0);
    for (var stone = 0; stone < 3; stone++) {
      await tapSlot(tester, 0);
    }
    await tapSlot(tester, 1);
    await tapSlot(tester, 1);
    await tapSlot(tester, 2);
    await tapSlot(tester, 2);
    await tapSlot(tester, 3);
    expect(state(tester).play.piles, [3, 2, 2, 1]);
    for (var dither = 0; dither < 5; dither++) {
      await tapSlot(tester, 3);
      await tapSlot(tester, 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.piles, [3, 2, 2, 1]);
    await shoot(tester, 'eightstill');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'stone-iphone-14.png',
      'twelvedeals-iphone-14.png',
      'stairofsix.png',
      'longsix.png',
      'middleroad.png',
      'midpile.png',
      'showme.png',
      'why.png',
      'eightstill.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
