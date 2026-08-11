import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/garden.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every evening in them was read by taps, so nothing in the pictures is a
/// garden the game could not show.
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
    testWidgets('the evenings on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'evenings-${phone.key}');
    });

    testWidgets('a garden complaining on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await shoot(tester, 'complaining-${phone.key}');
    });

    testWidgets('one read on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await name(tester, 7);
      expect(state(tester).play.settled, isTrue);
      await shoot(tester, 'read-${phone.key}');
    });
  }

  testWidgets('the why with the bed shaded', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showBeds, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a slip corrected from the tallies', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await name(tester, 4);
    expect(state(tester).play.slips, 1);
    await shoot(tester, 'slip');
  });

  testWidgets('the double draught owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await name(tester, 7);
    expect(state(tester).play.settled, isTrue);
    await shoot(tester, 'double');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'evenings-iphone-14.png',
      'complaining-iphone-14.png',
      'read-iphone-14.png',
      'why.png',
      'slip.png',
      'double.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
