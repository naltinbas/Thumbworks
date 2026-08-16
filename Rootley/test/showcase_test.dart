import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rootland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every walk in them was set by taps on the dials, so nothing in the
/// pictures is a setting the game could not reach.
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

    testWidgets('the seven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setDials(tester, 7, 3);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'seven-${phone.key}');
    });
  }

  testWidgets('the fourth home', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await walkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourth');
  });

  testWidgets('the full round', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setDials(tester, 11, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'round');
  });

  testWidgets('the nine', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setDials(tester, 9, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'nine');
  });

  testWidgets('midway, a full base of fourteen on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await setDials(tester, 14, 3);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await turn(tester, 'base', 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the eight admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setDials(tester, 8, 7);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'eight');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'seven-iphone-14.png',
      'fourth.png',
      'round.png',
      'nine.png',
      'midway.png',
      'showme.png',
      'why.png',
      'eight.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
