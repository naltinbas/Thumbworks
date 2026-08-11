import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ferry.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every crossing in them was tapped, so nothing in the pictures is a
/// river the game could not reach.
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
    testWidgets('the ferries on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'ferries-${phone.key}');
    });

    testWidgets('the three and three mid-river on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      for (var crossing = 0; crossing < 4; crossing++) {
        for (final who in state(tester).play.nextLoad!) {
          await tapChip(tester, who);
        }
        await rowBoat(tester);
      }
      await shoot(tester, 'rowing-${phone.key}');
    });

    testWidgets('a ferry landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await rowItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'landed-${phone.key}');
    });
  }

  testWidgets('a load aboard', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapChip(tester, 0);
    await tapChip(tester, 2);
    await shoot(tester, 'aboard');
  });

  testWidgets('a refusal by name', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapChip(tester, 0);
    await rowBoat(tester);
    await shoot(tester, 'refusal');
  });

  testWidgets('the four and four counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'fourandfour');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'ferries-iphone-14.png',
      'rowing-iphone-14.png',
      'landed-iphone-14.png',
      'aboard.png',
      'refusal.png',
      'fourandfour.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
