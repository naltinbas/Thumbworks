import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/denland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every wrestler in them was stepped in by a tap, so nothing in the
/// pictures is a line the game could not reach.
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

    testWidgets('the four lined up on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await stepAll(tester, [0, 3, 2, 1]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'four-${phone.key}');
    });
  }

  testWidgets('the five lined up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await stepAll(tester, [4, 3, 2, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('the ring closed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await stepAll(tester, [0, 4, 1, 3, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ring');
  });

  testWidgets('the six lined up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await stepAll(tester, [0, 5, 4, 1, 3, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('a yard mid-line, a link broken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await stepAll(tester, [0, 1, 2]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midline');
  });

  testWidgets('show me ringing a wrestler', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await stepAll(tester, [0]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the champion\'s ring admitted, the line holding and the ring open',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await stepAll(tester, [4, 3, 2, 1, 0]);
    for (var dither = 0; dither < 4; dither++) {
      await stepAll(tester, [0, 0]);
    }
    expect(state(tester).play.moves, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'championsring');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'four-iphone-14.png',
      'five.png',
      'ring.png',
      'six.png',
      'midline.png',
      'showme.png',
      'why.png',
      'championsring.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
