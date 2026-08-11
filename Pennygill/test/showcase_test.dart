import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennygill/toss/call.dart';

import 'support/fonts.dart';
import 'support/toss.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every table in them was called and tossed by taps, so nothing in the
/// pictures is a match the game could not deal.
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
    testWidgets('the tables on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'tables-${phone.key}');
    });

    testWidgets('a call being made on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await shoot(tester, 'calling-${phone.key}');
    });

    testWidgets('a run of flips on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await call(tester, const Call(6));
      for (var toss = 0; toss < 7 && !state(tester).play.roundOver; toss++) {
        await press(tester, 'Toss');
      }
      await shoot(tester, 'tossing-${phone.key}');
    });
  }

  testWidgets('the ring of calls', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await call(tester, const Call(6));
    await press(tester, 'Why');
    expect(state(tester).showRing, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the turned table shown its reply', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'turned');
  });

  testWidgets('a match settled and owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await call(tester, const Call(6));
    await tossItOut(tester);
    await shoot(tester, 'settled');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'tables-iphone-14.png',
      'calling-iphone-14.png',
      'tossing-iphone-14.png',
      'why.png',
      'turned.png',
      'settled.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
