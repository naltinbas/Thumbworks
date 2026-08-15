import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every peg in them was tapped, so nothing in the pictures is a
/// wheel the game could not reach.
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

    testWidgets('the right corner landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await cordAll(tester, [(-5, 0), (5, 0), (3, 4)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'rightcorner-${phone.key}');
    });
  }

  testWidgets('the sharp three landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await cordAll(tester, [(5, 0), (-3, 4), (-3, -4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sharpthree');
  });

  testWidgets('the square wheel landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await cordAll(tester, [(3, 4), (-4, 3), (-3, -4), (4, -3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'squarewheel');
  });

  testWidgets('the given two landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await cordByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'giventwo');
  });

  testWidgets('a wheel mid-cording, a blunt corner', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await cordAll(tester, [(5, 0), (4, 3), (3, 4)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midcording');
  });

  testWidgets('show me ringing a peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the off diameter admitted, a square corner across a diameter standing',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await cordAll(tester, [(-5, 0), (5, 0), (3, 4)]);
    for (var dither = 0; dither < 4; dither++) {
      await cordAll(tester, [(3, 4), (3, 4)]);
    }
    await tapPeg(tester, (3, 4));
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'offdiameter');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'rightcorner-iphone-14.png',
      'sharpthree.png',
      'squarewheel.png',
      'giventwo.png',
      'midcording.png',
      'showme.png',
      'why.png',
      'offdiameter.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
