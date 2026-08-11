import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wick.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every press in them was tapped, so nothing in the pictures is a board
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
    testWidgets('the wicks on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'wicks-${phone.key}');
    });

    testWidgets('the full five part-pressed on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 4);
      await lamp(tester, state(tester).play.next!);
      await lamp(tester, state(tester).play.next!);
      await lamp(tester, state(tester).play.next!);
      await shoot(tester, 'pressing-${phone.key}');
    });

    testWidgets('a board gone dark on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await pressItDark(tester);
      expect(state(tester).play.isDark, isTrue);
      await shoot(tester, 'dark-${phone.key}');
    });
  }

  testWidgets('an answer rimmed on the ring', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).answer, isNot(0));
    await shoot(tester, 'why');
  });

  testWidgets('the quiet pattern on the unquenchable', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    expect(state(tester).quiet, isNot(0));
    await shoot(tester, 'unquenchable');
  });

  testWidgets('a wandering press called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lamp(tester, 4);
    await shoot(tester, 'wandered');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'wicks-iphone-14.png',
      'pressing-iphone-14.png',
      'dark-iphone-14.png',
      'why.png',
      'unquenchable.png',
      'wandered.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
