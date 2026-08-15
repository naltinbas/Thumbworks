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
/// Every book in them was nudged by taps, so nothing in the pictures
/// is a stack the game could not reach.
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

    testWidgets('the four a whole book out on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await lean(tester, [12, 6, 4, 2]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'four-${phone.key}');
    });
  }

  testWidgets('the one at half', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await lean(tester, [12]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'one');
  });

  testWidgets('the two at three quarters', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lean(tester, [12, 6]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the five at a book and an eighth', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await lean(tester, [12, 6, 4, 3, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('a stack mid-lean, toppling', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await lean(tester, [12, 8, 0, 0]);
    expect(state(tester).play.stands, isFalse);
    await shoot(tester, 'midlean');
  });

  testWidgets('show me ringing a half', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await lean(tester, [12, 6]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three admitted, at eleven twelfths',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lean(tester, [12, 6, 4]);
    for (var dither = 0; dither < 2; dither++) {
      await nudge(tester, 0, 1);
      await nudge(tester, 0, -1);
    }
    expect(state(tester).play.moves, 26);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'three');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'four-iphone-14.png',
      'one.png',
      'two.png',
      'five.png',
      'midlean.png',
      'showme.png',
      'why.png',
      'three.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
