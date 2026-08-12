import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yard.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every weight in them was chosen by taps, so nothing in the
/// pictures is a yard the game could not reach.
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
    testWidgets('the yard on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yard-${phone.key}');
    });

    testWidgets('the six weighed clean on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await chooseAll(tester, const [11, 17, 20, 22, 23, 24]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'six-${phone.key}');
    });
  }

  testWidgets('a clean three weighed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await chooseAll(tester, const [1, 2, 4]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the beam level on a clash', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await chooseAll(tester, const [3, 5, 8, 11]);
    expect(state(tester).play.balanced, isNotNull);
    await shoot(tester, 'level');
  });

  testWidgets('the five mid-choosing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await chooseAll(tester, const [20, 23, 24]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midchoose');
  });

  testWidgets('show me pointing a weight', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seventh admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var choosing = 0; choosing < 14; choosing++) {
      await tapWeight(tester, 1);
    }
    await shoot(tester, 'seventh');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yard-iphone-14.png',
      'six-iphone-14.png',
      'three.png',
      'level.png',
      'midchoose.png',
      'showme.png',
      'why.png',
      'seventh.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
