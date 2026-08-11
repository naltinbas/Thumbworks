import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hoard.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every hoard in them was taken by taps, so nothing in the pictures is a
/// standing the game could not reach.
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
    testWidgets('the hoards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hoards-${phone.key}');
    });

    testWidgets('a take part marked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await mark(tester);
      await mark(tester);
      await shoot(tester, 'marking-${phone.key}');
    });

    testWidgets('one won on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await winItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'won-${phone.key}');
    });
  }

  testWidgets('the clusters ringed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).showClusters, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the fibonacci hoard owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'fibonacci');
  });

  testWidgets('a wrong take called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await take(tester, 5);
    expect(state(tester).saying, contains('handed the split over'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hoards-iphone-14.png',
      'marking-iphone-14.png',
      'won-iphone-14.png',
      'why.png',
      'fibonacci.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
