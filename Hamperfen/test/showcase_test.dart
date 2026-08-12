import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every basket in them was taken by taps, so nothing in the
/// pictures is a fen the game could not reach.
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
    testWidgets('the fenland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fenland-${phone.key}');
    });

    testWidgets('the six taken on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await takeAll(tester, const [3, 5, 6, 9, 10, 12]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'six-${phone.key}');
    });
  }

  testWidgets('a free pair taken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await takeAll(tester, const [3, 5]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'pair');
  });

  testWidgets('a swallowing called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await takeAll(tester, const [1, 3, 8]);
    expect(state(tester).play.swallowings, isNotEmpty);
    await shoot(tester, 'swallowing');
  });

  testWidgets('the five mid-picking', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await takeAll(tester, const [3, 5, 6]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midpick');
  });

  testWidgets('show me ringing a basket', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seventh admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var taking = 0; taking < 14; taking++) {
      await tapBasket(tester, 0);
    }
    await shoot(tester, 'seventh');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fenland-iphone-14.png',
      'six-iphone-14.png',
      'pair.png',
      'swallowing.png',
      'midpick.png',
      'showme.png',
      'why.png',
      'seventh.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
