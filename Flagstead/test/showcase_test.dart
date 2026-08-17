import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hallland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// On the board shots the hall was set on its dials and the peg stood
/// by a tap, so no standing pictured is one the game could not reach.
/// The sham shots show the mark, standing with no taps behind it.
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

    testWidgets('the peg within on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await setStanding(tester, 6, 8, 3, 4);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'within-${phone.key}');
    });
  }

  testWidgets('the whole four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'whole');
  });

  testWidgets('the even corners', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'even');
  });

  testWidgets('the fifty', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fifty');
  });

  testWidgets('the leaning hall, admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await standAt(tester, 0, 0);
    await standAt(tester, 5, 5);
    await standAt(tester, -3, 7);
    await standAt(tester, 1, 1);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'leaning');
  });

  testWidgets('a big hall with the peg out, on the small phone',
      (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await setStanding(tester, 8, 8, 10, 10);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'outside');
  });

  testWidgets('show me naming the standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'within-iphone-14.png',
      'whole.png',
      'even.png',
      'fifty.png',
      'leaning.png',
      'outside.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
