import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every frame in them was hung by a tap, so nothing in the pictures is
/// a wall the game could not reach.
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

    testWidgets('the nine on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await hangByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nine-${phone.key}');
    });
  }

  testWidgets('the last five, mid-hanging', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await hang(tester, 4, 18, 14);
    await hang(tester, 7, 15, 18);
    await takeFrame(tester, 9);
    expect(state(tester).play.held, 9);
    await shoot(tester, 'lastfive');
  });

  testWidgets('the other nine', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await hangByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'othernine');
  });

  testWidgets('the ten', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await hangByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ten');
  });

  testWidgets('a wrong hanging, the 10 where the 14 goes', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await hang(tester, 18, 0, 0);
    await hang(tester, 10, 18, 0);
    await hang(tester, 15, 0, 18);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'wrong');
  });

  testWidgets('show me ringing the place', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await hang(tester, 18, 0, 0);
    await takeFrame(tester, 14);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the one on the rim admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final (s, x, y) in [(18, 0, 0), (14, 18, 0), (4, 18, 14), (10, 22, 14), (15, 0, 18), (7, 15, 18), (1, 22, 24), (9, 23, 24), (8, 15, 25)]) {
      await hang(tester, s, x, y);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'rim');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'nine-iphone-14.png',
      'lastfive.png',
      'othernine.png',
      'ten.png',
      'wrong.png',
      'showme.png',
      'why.png',
      'rim.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
