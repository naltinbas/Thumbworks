import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tower.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every move in them was tapped, so nothing in the pictures is a board
/// the game could not reach.
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
    testWidgets('the towers on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'towers-${phone.key}');
    });

    testWidgets('the fourth spindle mid-raise on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      for (var move = 0; move < 6; move++) {
        final next = state(tester).play.next!;
        await lift(tester, next.$1, next.$2);
      }
      await shoot(tester, 'raising-${phone.key}');
    });

    testWidgets('a tower home on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await raiseItHome(tester);
      expect(state(tester).play.isHome, isTrue);
      await shoot(tester, 'home-${phone.key}');
    });
  }

  testWidgets('a round lifted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapSpindle(tester, 0);
    expect(state(tester).lifted, 0);
    await shoot(tester, 'liftedround');
  });

  testWidgets('the three voices asked why', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the wager and its floor', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    await shoot(tester, 'wager');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'towers-iphone-14.png',
      'raising-iphone-14.png',
      'home-iphone-14.png',
      'liftedround.png',
      'why.png',
      'wager.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
