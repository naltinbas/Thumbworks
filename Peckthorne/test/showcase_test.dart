import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardring.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every flip in them was tapped, so nothing in the pictures is a
/// pecking the game could not reach.
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
    testWidgets('the yard on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yard-${phone.key}');
    });

    testWidgets('the full court crowned on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await crownByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'court-${phone.key}');
    });
  }

  testWidgets('the round of three crowned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapPair(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'round');
  });

  testWidgets('the three of four crowned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await crownByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeoffour');
  });

  testWidgets('the four of five crowned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await crownByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fouroffive');
  });

  testWidgets('a pecking mid-settle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapPair(tester, 3);
    await tapPair(tester, 7);
    expect(state(tester).play.moves, 2);
    await shoot(tester, 'midflip');
  });

  testWidgets('show me ringing a pair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the pair of kings admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var dither = 0; dither < 12; dither++) {
      await tapPair(tester, dither % 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nopair');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yard-iphone-14.png',
      'court-iphone-14.png',
      'round.png',
      'threeoffour.png',
      'fouroffive.png',
      'midflip.png',
      'showme.png',
      'why.png',
      'nopair.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
