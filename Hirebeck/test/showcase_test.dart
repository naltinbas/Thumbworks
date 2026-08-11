import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/book.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every booking in them was tapped, so nothing in the pictures is a day
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
    testWidgets('the days on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'days-${phone.key}');
    });

    testWidgets('the busy day part-booked on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      for (var step = 0; step < 3; step++) {
        await tapHiring(tester, state(tester).play.next!);
      }
      await shoot(tester, 'booking-${phone.key}');
    });

    testWidgets('a book filled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await bookItFull(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'filled-${phone.key}');
    });
  }

  testWidgets('a clash on the book', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapHiring(tester, 0);
    await tapHiring(tester, 1);
    expect(state(tester).play.clashes, isNotEmpty);
    await shoot(tester, 'clash');
  });

  testWidgets('the o\'clocks struck gold', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    expect(state(tester).strikes, isNotEmpty);
    await shoot(tester, 'strikes');
  });

  testWidgets('the extra guest counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'extraguest');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'days-iphone-14.png',
      'booking-iphone-14.png',
      'filled-iphone-14.png',
      'clash.png',
      'strikes.png',
      'extraguest.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
