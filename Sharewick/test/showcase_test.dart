import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/trioland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every trio in them was picked by a tap, so nothing in the pictures is
/// a family the game could not reach.
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

  const even = ['ABC', 'ABD', 'ACE', 'ADF', 'AEF', 'BCF', 'BDE', 'BEF', 'CDE', 'CDF'];
  const star = ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF'];

  for (final phone in phones.entries) {
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the ten on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await pickAll(tester, even);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ten-${phone.key}');
    });
  }

  testWidgets('the star', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await pickAll(tester, star);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'star');
  });

  testWidgets('the even hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pickAll(tester, even);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'even');
  });

  testWidgets('the fifteen', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await pickAll(tester, [...star, 'BCD', 'BCE', 'BCF', 'BDE', 'BDF']);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fifteen');
  });

  testWidgets('midway, a pair apart, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await pickAll(tester, ['ABC', 'ABD', 'ACE', 'DEF']);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the trio', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pickAll(tester, ['ABC', 'ABD']);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the eleven admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await pickAll(tester, [...star, 'BCD', 'BCD', 'BCE', 'BCE', 'BCF']);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'eleven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ten-iphone-14.png',
      'star.png',
      'even.png',
      'fifteen.png',
      'midway.png',
      'showme.png',
      'why.png',
      'eleven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
