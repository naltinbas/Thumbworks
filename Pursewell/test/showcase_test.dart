import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/well.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every coin in them was tapped, so nothing in the pictures is a
/// purse the game could not reach.
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
    testWidgets('the well on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'well-${phone.key}');
    });

    testWidgets('the nineteen paid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await payAll(tester, const [13, 5, 1]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nineteen-${phone.key}');
    });
  }

  testWidgets('the eleven paid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await payAll(tester, const [8, 3]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eleven');
  });

  testWidgets('neighbours called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await payAll(tester, const [8, 2, 1]);
    await shoot(tester, 'neighbours');
  });

  testWidgets('the thirty mid-pay', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await payAll(tester, const [21, 8]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midpay');
  });

  testWidgets('show me pointing a coin', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the second way admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await payAll(tester, const [8, 3, 1]);
    for (var move = 3; move < 12; move++) {
      await tapCoin(tester, 21);
    }
    await shoot(tester, 'secondway');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'well-iphone-14.png',
      'nineteen-iphone-14.png',
      'eleven.png',
      'neighbours.png',
      'midpay.png',
      'showme.png',
      'why.png',
      'secondway.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
