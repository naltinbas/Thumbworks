import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/green.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every card in them was paired by taps, so nothing in the pictures is a
/// green the game could not reach.
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
    testWidgets('the greens on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'greens-${phone.key}');
    });

    testWidgets('a round part paired on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      final next = state(tester).play.next!;
      await pair(tester, next.$1, next.$2);
      final again = state(tester).play.next!;
      await pair(tester, again.$1, again.$2);
      await shoot(tester, 'pairing-${phone.key}');
    });

    testWidgets('one written on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await writeItAll(tester);
      expect(state(tester).play.isWritten, isTrue);
      await shoot(tester, 'written-${phone.key}');
    });
  }

  testWidgets('the wheel strung as ghosts', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showWheel, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the short card saying its breath', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'short');
  });

  testWidgets('a side picked and waiting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await pick(tester, 2);
    expect(state(tester).play.chosen, 2);
    await shoot(tester, 'picked');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'greens-iphone-14.png',
      'pairing-iphone-14.png',
      'written-iphone-14.png',
      'why.png',
      'short.png',
      'picked.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
