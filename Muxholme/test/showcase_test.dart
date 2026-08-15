import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/muxland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every step in them was made by a tap, so nothing in the pictures is
/// a string the game could not reach.
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

    testWidgets('MUIIU derived on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await deriveByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'muiiu-${phone.key}');
    });
  }

  testWidgets('MIU derived', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Rule I: add U');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'miu');
  });

  testWidgets('MIIU derived', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await deriveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'miiu');
  });

  testWidgets('MUI derived', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await deriveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'mui');
  });

  testWidgets('a string mid-derivation, rule three ready', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await makeAll(tester, [(2, 0), (2, 0), (2, 0)]);
    expect(state(tester).play.string, 'MIIIIIIII');
    await shoot(tester, 'midderivation');
  });

  testWidgets('show me ringing the letters', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await makeAll(tester, [(2, 0), (2, 0), (2, 0)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('MU admitted, twelve steps', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    while (!state(tester).play.isOver) {
      final ms = state(tester).play.moves;
      await make(tester, ms.contains((2, 0)) ? (2, 0) : ms.contains((1, 0)) ? (1, 0) : ms.first);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'mu');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'muiiu-iphone-14.png',
      'miu.png',
      'miiu.png',
      'mui.png',
      'midderivation.png',
      'showme.png',
      'why.png',
      'mu.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
