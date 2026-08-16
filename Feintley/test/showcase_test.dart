import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/benchland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every setting in them was reached by the dials, so nothing in the
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

    testWidgets('the liar of two on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setTest(tester, 341, 2);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'liar-${phone.key}');
    });
  }

  testWidgets('the honest prime', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setTest(tester, 1009, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'honest');
  });

  testWidgets('the liar of three', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setTest(tester, 91, 3);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the Carmichael', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setTest(tester, 561, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'carmichael');
  });

  testWidgets('midway, a composite caught out, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await setTest(tester, 91, 2);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the step', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setTest(tester, 551, 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the failing prime admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await turn(tester, 'n', 10);
    for (var k = 0; k < 6; k++) {
      await turn(tester, 'n', 1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'failing');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'liar-iphone-14.png',
      'honest.png',
      'three.png',
      'carmichael.png',
      'midway.png',
      'showme.png',
      'why.png',
      'failing.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
