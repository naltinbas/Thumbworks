import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every brick in them was laid by taps, so nothing in the pictures is
/// a yard the game could not reach.
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

    testWidgets('the eight yard paved on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await paveByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'eightyard-${phone.key}');
    });
  }

  testWidgets('the four yard paved', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapAll(tester, [1, 4, 8, 12]);
    await face(tester, false);
    await tapFlag(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fouryard');
  });

  testWidgets('the five yard paved', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fiveyard');
  });

  testWidgets('the seven yard paved', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await paveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sevenyard');
  });

  testWidgets('a yard mid-paving, facing down', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [0, 3, 8, 11]);
    await face(tester, false);
    await tapAll(tester, [6, 7]);
    expect(state(tester).play.bricks, hasLength(6));
    await shoot(tester, 'midpave');
  });

  testWidgets('show me ringing a flag', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the corner drain stuck, flags bare', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await layUntilStuck(tester);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'stuck');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'eightyard-iphone-14.png',
      'fouryard.png',
      'fiveyard.png',
      'sevenyard.png',
      'midpave.png',
      'showme.png',
      'why.png',
      'stuck.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
