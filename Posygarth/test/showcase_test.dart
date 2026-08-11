import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/garth.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every posy in them was armed and planted by taps, so nothing in the
/// pictures is a garth the game could not grow.
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
    testWidgets('the garths on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'garths-${phone.key}');
    });

    testWidgets('a garth part planted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      for (var posies = 0; posies < 4; posies++) {
        await press(tester, 'Show me');
        await tapBed(tester, state(tester).pointing);
      }
      await shoot(tester, 'planting-${phone.key}');
    });

    testWidgets('one bloomed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await bloomItAll(tester);
      expect(state(tester).play.isBloomed, isTrue);
      await shoot(tester, 'bloomed-${phone.key}');
    });
  }

  testWidgets('the planting as ghosts', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showPlanting, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the pair of pairs owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'pair');
  });

  testWidgets('a clash refused with its reason', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await plant(tester, 0, 1, 2);
    await armColour(tester, 0);
    await tapBed(tester, 1);
    expect(state(tester).saying, contains('flower is in this row'));
    await shoot(tester, 'clash');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'garths-iphone-14.png',
      'planting-iphone-14.png',
      'bloomed-iphone-14.png',
      'why.png',
      'pair.png',
      'clash.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
