import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hamland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every row in them was kept by a tap, so nothing in the pictures is
/// a ledger the game could not reach.
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

    testWidgets('ninety-nine by nine kept on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await keepByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ninetynine-${phone.key}');
    });
  }

  testWidgets('thirteen by seven kept', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapAll(tester, [0, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirteen');
  });

  testWidgets('twenty-seven by nineteen kept', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await keepByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twentyseven');
  });

  testWidgets('forty by twenty-five kept', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await keepByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'forty');
  });

  testWidgets('a ledger mid-keeping, over', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [0, 1, 6]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midkeeping');
  });

  testWidgets('show me ringing a row', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapAll(tester, [0]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('two rows admitted, short', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapAll(tester, [2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'tworows');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ninetynine-iphone-14.png',
      'thirteen.png',
      'twentyseven.png',
      'forty.png',
      'midkeeping.png',
      'showme.png',
      'why.png',
      'tworows.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
