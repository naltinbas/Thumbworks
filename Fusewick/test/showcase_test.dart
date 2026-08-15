import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every end in them was lit by a tap and every minute burnt by one, so
/// nothing in the pictures is a moment the game could not reach.
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
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the forty-five struck on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await strikeByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fortyfive-${phone.key}');
    });
  }

  testWidgets('the thirty struck', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await strikeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirty');
  });

  testWidgets('the seventy-five struck', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await strikeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'seventyfive');
  });

  testWidgets('the fifty-two and a half struck', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await strikeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fiftytwo');
  });

  testWidgets('a time mid-burn, one fuse out and one alight', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await light(tester, 0, false);
    await light(tester, 1, false);
    await light(tester, 1, true);
    await burn(tester);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midburn');
  });

  testWidgets('show me ringing an end', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the twenty admitted, the first burnout past it',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await light(tester, 0, false);
    await light(tester, 0, true);
    await light(tester, 1, false);
    await burn(tester);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'twenty');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fortyfive-iphone-14.png',
      'thirty.png',
      'seventyfive.png',
      'fiftytwo.png',
      'midburn.png',
      'showme.png',
      'why.png',
      'twenty.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
