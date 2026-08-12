import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/buryland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every candle in them was tapped, so nothing in the pictures is a
/// pick the game could not reach.
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
    testWidgets('the bury on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'bury-${phone.key}');
    });

    testWidgets('the thirty-one cut on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      for (final spot in [0, 2, 4, 5, 8, 9]) {
        await tapSpot(tester, spot);
      }
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'thirtyone-${phone.key}');
    });
  }

  testWidgets('the eight cut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    for (final spot in [0, 3, 6, 9]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eight');
  });

  testWidgets('the sixteen cut', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    for (final spot in [0, 2, 5, 7, 10]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sixteen');
  });

  testWidgets('the thirty cut through the clump', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    for (final spot in [0, 2, 4, 6, 8, 10]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.slices, 30);
    await shoot(tester, 'thirty');
  });

  testWidgets('a cake mid-set', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    for (final spot in [0, 3, 7]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.picked, hasLength(3));
    await shoot(tester, 'midset');
  });

  testWidgets('show me ringing a spot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the thirty-two admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Six spread candles cut thirty-one, the nearest the cake
    // comes; dither the last candle till the bury admits.
    for (final spot in [0, 2, 4, 5, 8, 9]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.slices, 31);
    for (var dither = 0; dither < 10; dither++) {
      await tapSpot(tester, 9);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.slices, 31);
    await shoot(tester, 'thirtytwo');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'bury-iphone-14.png',
      'thirtyone-iphone-14.png',
      'eight.png',
      'sixteen.png',
      'thirty.png',
      'midset.png',
      'showme.png',
      'why.png',
      'thirtytwo.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
