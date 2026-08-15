import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pick in them was tapped, so nothing in the pictures is a
/// board the game could not reach.
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

    testWidgets('the twelve rows met on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await tapNumber(tester, 60);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twelverows-${phone.key}');
    });
  }

  testWidgets('the seven rows met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapNumber(tester, 64);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sevenrows');
  });

  testWidgets('the nine rows met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapNumber(tester, 100);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ninerows');
  });

  testWidgets('the ten rows met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'tenrows');
  });

  testWidgets('an asking mid-pick, ninety picked for the twelve', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapNumber(tester, 90);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Again');
    await tapNumber(tester, 42);
    expect(state(tester).play.rows, 8);
    await shoot(tester, 'midpick');
  });

  testWidgets('show me ringing a heap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapNumber(tester, 30);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the thirteen rows admitted, ninety-six standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var n = 1; n <= 12; n++) {
      await tapNumber(tester, n * 8);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.heap, 96);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'thirteenrows');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twelverows-iphone-14.png',
      'sevenrows.png',
      'ninerows.png',
      'tenrows.png',
      'midpick.png',
      'showme.png',
      'why.png',
      'thirteenrows.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
