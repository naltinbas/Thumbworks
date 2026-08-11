import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/cheese.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every shape in them was bitten by taps, so nothing in the pictures is a
/// block the game could not reach.
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
    testWidgets('the shelf on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'shelf-${phone.key}');
    });

    testWidgets('a block mid-bitten on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      final next = state(tester).play.next!;
      await bite(tester, next.$1, next.$2);
      await shoot(tester, 'biting-${phone.key}');
    });

    testWidgets('one won on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await winItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'won-${phone.key}');
    });
  }

  testWidgets('the mirror line on the square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    final next = state(tester).play.next!;
    await bite(tester, next.$1, next.$2);
    await press(tester, 'Why');
    expect(state(tester).showWhy, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the wrong bite called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await bite(tester, 3, 3);
    expect(state(tester).saying, contains('has the block now'));
    await shoot(tester, 'costly');
  });

  testWidgets('the second mouse block saying what it is for', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await shoot(tester, 'second');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'shelf-iphone-14.png',
      'biting-iphone-14.png',
      'won-iphone-14.png',
      'why.png',
      'costly.png',
      'second.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
