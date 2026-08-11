import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ring.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every turn in them was tapped, so nothing in the pictures is a ring
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
    testWidgets('the watches on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'watches-${phone.key}');
    });

    testWidgets('the sixteen part-set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      for (var turnsMade = 0; turnsMade < 5; turnsMade++) {
        await turn(tester, state(tester).play.next!);
      }
      await shoot(tester, 'setting-${phone.key}');
    });

    testWidgets('a watch full on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setItFull(tester);
      expect(state(tester).play.isFull, isTrue);
      await shoot(tester, 'full-${phone.key}');
    });
  }

  testWidgets('the locked watch mid-set', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await turn(tester, state(tester).play.next!);
    await press(tester, 'Show me');
    await shoot(tester, 'locked');
  });

  testWidgets('the clashes chorded', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await turn(tester, 0);
    await turn(tester, 1);
    await press(tester, 'Why');
    expect(state(tester).showClashes, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the short ring counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await turn(tester, 0);
    await turn(tester, 2);
    await press(tester, 'Why');
    await shoot(tester, 'shortring');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'watches-iphone-14.png',
      'setting-iphone-14.png',
      'full-iphone-14.png',
      'locked.png',
      'why.png',
      'shortring.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
