import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hedge.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every hedge in them was cut by taps, so nothing in the pictures is a
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
    testWidgets('the hedges on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hedges-${phone.key}');
    });

    testWidgets('a hedge mid-cut on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      final next = state(tester).play.next!;
      await cut(tester, next.$1, next.$2);
      await shoot(tester, 'cutting-${phone.key}');
    });

    testWidgets('one held on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await holdItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'heldhedge-${phone.key}');
    });
  }

  testWidgets('the worths written on the stalks', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showWorth, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the even hedge owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'even');
  });

  testWidgets('a spendthrift cut called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await cut(tester, 1, 1);
    expect(state(tester).saying, contains('spent more than it took'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hedges-iphone-14.png',
      'cutting-iphone-14.png',
      'heldhedge-iphone-14.png',
      'why.png',
      'even.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
