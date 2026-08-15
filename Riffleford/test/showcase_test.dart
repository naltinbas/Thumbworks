import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every drop in them was tapped, so nothing in the pictures is a
/// deck the game could not reach.
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

    testWidgets('the even cut dealt on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await dropAll(tester, 'ABBAABBA');
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'evencut-${phone.key}');
    });
  }

  testWidgets('the odd cut dealt', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await dropAll(tester, 'BABBAABB');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oddcut');
  });

  testWidgets('the unturned packet dealt right', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await riffleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'unturned');
  });

  testWidgets('the three kinds dealt', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await dropAll(tester, 'ABABBABBA');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threekinds');
  });

  testWidgets('a deck mid-riffle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await dropAll(tester, 'ABBA');
    expect(state(tester).play.blocks, [true, true]);
    await shoot(tester, 'midriffle');
  });

  testWidgets('show me ringing a pile', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await dropAll(tester, 'AAB');
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the two reds admitted, the whole deck dealt', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await dropAll(tester, 'BBAABBAB');
    expect(state(tester).play.moves, 8);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'tworeds');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'evencut-iphone-14.png',
      'oddcut.png',
      'unturned.png',
      'threekinds.png',
      'midriffle.png',
      'showme.png',
      'why.png',
      'tworeds.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
