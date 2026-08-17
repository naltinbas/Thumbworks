import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/isleland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// On the board shots every villager was named by a tap on that
/// villager, so no naming pictured is one the game could not reach. The
/// sham shots show the mark, standing with no taps behind it.
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

    testWidgets('the three on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await nameAll(tester, const [false, true, false]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'three-${phone.key}');
    });
  }

  testWidgets('the two', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('the quiet four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await nameAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'quiet');
  });

  testWidgets('the paradox, admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapVillager(tester, 0);
    await tapVillager(tester, 1);
    await tapVillager(tester, 2);
    await tapVillager(tester, 0);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'paradox');
  });

  testWidgets('a naming that catches somebody out, on the small phone',
      (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await nameAll(tester, const [true, true, false, true]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'caught');
  });

  testWidgets('show me naming the villager', (tester) async {
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
      'three-iphone-14.png',
      'two.png',
      'four.png',
      'quiet.png',
      'paradox.png',
      'caught.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
