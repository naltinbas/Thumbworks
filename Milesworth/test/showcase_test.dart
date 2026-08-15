import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every mark in them was set by a tap, so nothing in the pictures is
/// a lane the game could not reach.
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

    testWidgets('the fifteen run on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await markAll(tester, [4, 6]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fifteen-${phone.key}');
    });
  }

  testWidgets('the twenty-one run', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await markAll(tester, [1, 6]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twentyone');
  });

  testWidgets('the thirteen run', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await markAll(tester, [6, 7]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirteen');
  });

  testWidgets('the forty-five run', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await markAll(tester, [7, 11]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fortyfive');
  });

  testWidgets('a lane mid-marking, a run short', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await markAll(tester, [5, 9]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midmarking');
  });

  testWidgets('show me ringing a milestone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the sixteen admitted, a run of fifteen standing',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await markAll(tester, [1, 5]);
    for (var dither = 0; dither < 5; dither++) {
      await markAll(tester, [5, 5]);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'sixteen');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fifteen-iphone-14.png',
      'twentyone.png',
      'thirteen.png',
      'fortyfive.png',
      'midmarking.png',
      'showme.png',
      'why.png',
      'sixteen.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
