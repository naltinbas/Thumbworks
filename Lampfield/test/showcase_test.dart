import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lampland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every lamp in them was lit by a tap, so nothing in the pictures is
/// a message the game could not reach.
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

    testWidgets('in the code on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await sendByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'code-${phone.key}');
    });
  }

  testWidgets('four alight', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setMessage(tester, [0, 0, 1, 1, 1, 1, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('the dark line', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setMessage(tester, [0, 0, 0, 0, 0, 0, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'dark');
  });

  testWidgets('all alight', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setMessage(tester, [1, 1, 1, 1, 1, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'alight');
  });

  testWidgets('out of the code, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await tapLamp(tester, 1);
    expect(state(tester).play.inCode, isFalse);
    await shoot(tester, 'outofcode');
  });

  testWidgets('show me lighting a lamp', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('fooling the reader given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final lamp in [1, 2, 3, 4]) {
      await tapLamp(tester, lamp);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nofool');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'code-iphone-14.png',
      'four.png',
      'dark.png',
      'alight.png',
      'outofcode.png',
      'showme.png',
      'why.png',
      'nofool.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
