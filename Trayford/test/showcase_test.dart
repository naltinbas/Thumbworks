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
/// Every filling in them was tapped, so nothing in the pictures is a
/// tray the game could not reach.
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

    testWidgets('the old count met on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await tapSlot(tester, 23);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'oldcount-${phone.key}');
    });
  }

  testWidgets('the threes and fives met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapSlot(tester, 14);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threesandfives');
  });

  testWidgets('the fives and sevens met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fivesandsevens');
  });

  testWidgets('the fours and sixes met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapSlot(tester, 21);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'foursandsixes');
  });

  testWidgets('a tray mid-fill, one asking met', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapSlot(tester, 17);
    expect(state(tester).play.met, [true, false, false]);
    await shoot(tester, 'midfill');
  });

  testWidgets('show me ringing a slot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapSlot(tester, 5);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd and even admitted, thirteen eggs standing',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var count = 2; count <= 13; count++) {
      await tapSlot(tester, count);
    }
    expect(state(tester).play.moves, 12);
    expect(state(tester).play.eggs, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'oddandeven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'oldcount-iphone-14.png',
      'threesandfives.png',
      'fivesandsevens.png',
      'foursandsixes.png',
      'midfill.png',
      'showme.png',
      'why.png',
      'oddandeven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
