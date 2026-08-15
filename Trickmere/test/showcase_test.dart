import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every card in them was hidden or laid by a tap, so nothing in the
/// pictures is a table the game could not reach.
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

    testWidgets('the pair of hearts laid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await tapAll(tester, [32, 27, 12, 17, 47]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'pairofhearts-${phone.key}');
    });
  }

  testWidgets('the two pairs laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twopairs');
  });

  testWidgets('the three spades laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threespades');
  });

  testWidgets('the wrap round laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [13, 20, 36, 4, 40]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'wrapround');
  });

  testWidgets('a hand mid-lay, two cards down', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapAll(tester, [46, 41, 29]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midlay');
  });

  testWidgets('show me ringing a card', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the lone club admitted, the partner naming a heart',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapAll(tester, [31, 36, 47, 24]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'loneclub');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'pairofhearts-iphone-14.png',
      'twopairs.png',
      'threespades.png',
      'wrapround.png',
      'midlay.png',
      'showme.png',
      'why.png',
      'loneclub.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
