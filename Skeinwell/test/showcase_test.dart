import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/skeinland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every lane in them was laid by a tap on the board, so nothing in the
/// pictures is a village the game could not reach.
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

    testWidgets('the even ring on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'even-${phone.key}');
    });
  }

  testWidgets('the half lane', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setVillage(tester, [0, 1, 3, 6, 8, 9]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'halflane');
  });

  testWidgets('the two halves', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setVillage(tester, [0, 1, 3, 4, 6, 8, 9]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twohalves');
  });

  testWidgets('the full skein', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'full');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setVillage(tester, [0, 3, 4, 7, 9]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a lane', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('more than four given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setVillage(tester, [0, 1, 3, 4, 5, 6, 8, 9]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'morethanfour');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'even-iphone-14.png',
      'halflane.png',
      'twohalves.png',
      'full.png',
      'midway.png',
      'showme.png',
      'why.png',
      'morethanfour.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
