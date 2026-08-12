import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lowland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every dial in them was tapped, so nothing in the pictures is a
/// load the game could not reach.
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
    testWidgets('the low on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'low-${phone.key}');
    });

    testWidgets('the seven turns ground on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      // 9985 walks the full seven turns.
      await dialTo(tester, 0, 9);
      await dialTo(tester, 1, 9);
      await dialTo(tester, 2, 8);
      await dialTo(tester, 3, 5);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'seventurns-${phone.key}');
    });
  }

  testWidgets('the one turn ground', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await dialTo(tester, 0, 6);
    await dialTo(tester, 1, 2);
    await dialTo(tester, 2, 0);
    await dialTo(tester, 3, 0);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oneturn');
  });

  testWidgets('the three turns ground, the classic', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await dialTo(tester, 0, 3);
    await dialTo(tester, 1, 5);
    await dialTo(tester, 2, 2);
    await dialTo(tester, 3, 4);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeturns');
  });

  testWidgets('the standstill dialled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await dialTo(tester, 0, 6);
    await dialTo(tester, 1, 1);
    await dialTo(tester, 2, 7);
    await dialTo(tester, 3, 4);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'standstill');
  });

  testWidgets('a load mid-dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapDial(tester, 0);
    await tapDial(tester, 2);
    expect(state(tester).play.moves, 2);
    await shoot(tester, 'middial');
  });

  testWidgets('the barred door', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await dialTo(tester, 1, 1);
    await dialTo(tester, 2, 1);
    await dialTo(tester, 3, 1);
    expect(state(tester).play.barred, isTrue);
    await shoot(tester, 'barred');
  });

  testWidgets('show me ringing a dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the eighth turn admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // A full seven-turn road standing: the longest there is,
    // and one short of the asking for ever.
    await dialTo(tester, 0, 9);
    await dialTo(tester, 1, 9);
    await dialTo(tester, 2, 8);
    await dialTo(tester, 3, 5);
    var guard = 0;
    while (!state(tester).play.gaveUp && guard++ < 20) {
      await tapDial(tester, 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'eighthturn');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'low-iphone-14.png',
      'seventurns-iphone-14.png',
      'oneturn.png',
      'threeturns.png',
      'standstill.png',
      'middial.png',
      'barred.png',
      'showme.png',
      'why.png',
      'eighthturn.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
