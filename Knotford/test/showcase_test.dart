import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/knotland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every peg in them was stood by a tap, so nothing in the pictures is
/// a rope the game could not reach.
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

    testWidgets('the twelve squared on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await standAll(tester, [3, 7]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twelve-${phone.key}');
    });
  }

  testWidgets('the thirty squared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await standAll(tester, [5, 17]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirty');
  });

  testWidgets('the forty squared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await standAll(tester, [8, 23]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'forty');
  });

  testWidgets('the sixty squared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await standAll(tester, [15, 35]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sixty');
  });

  testWidgets('a rope mid-marking, a sharp corner', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await standAll(tester, [2, 7]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midmarking');
  });

  testWidgets('show me ringing a knot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd rope admitted, a blunt corner standing',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await standAll(tester, [5, 14]);
    for (var dither = 0; dither < 5; dither++) {
      await standAll(tester, [14, 14]);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'oddrope');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twelve-iphone-14.png',
      'thirty.png',
      'forty.png',
      'sixty.png',
      'midmarking.png',
      'showme.png',
      'why.png',
      'oddrope.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
