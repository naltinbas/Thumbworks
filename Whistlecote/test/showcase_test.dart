import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/coteland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every whistle in them was given by taps, so nothing in the pictures
/// is a marking the game could not reach.
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

    testWidgets('the five calls whistled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await markByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fivecalls-${phone.key}');
    });
  }

  testWidgets('the three calls whistled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapAll(tester, [2, 6, 7]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threecalls');
  });

  testWidgets('the four calls whistled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await markByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourcalls');
  });

  testWidgets('the long calls whistled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await markByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'longcalls');
  });

  testWidgets('a set mid-whistle, a clash', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [4, 8, 12]);
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.clashes, [(4, 8)]);
    await shoot(tester, 'midwhistle');
  });

  testWidgets('show me ringing a whistle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapAll(tester, [2]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the crowded calls admitted, one whistle starting another',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapAll(tester, [2, 6, 14, 15, 12]);
    await tapAll(tester, [12, 13, 13, 12, 12, 13, 13, 12]);
    expect(state(tester).play.moves, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'crowded');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fivecalls-iphone-14.png',
      'threecalls.png',
      'fourcalls.png',
      'longcalls.png',
      'midwhistle.png',
      'showme.png',
      'why.png',
      'crowded.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
