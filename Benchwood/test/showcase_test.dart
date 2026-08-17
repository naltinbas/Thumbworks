import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/benchland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// On the board shots every carry was made by a tap on the tool, so no
/// standing pictured is one the game could not reach. The sham shots
/// show the mark, standing with no taps behind it.
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

    testWidgets('belady\'s card on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await workByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'belady-${phone.key}');
    });
  }

  testWidgets('the first card', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await workByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'first');
  });

  testWidgets('the round', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await workByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'round');
  });

  testWidgets('the fourth slot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await workByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourth');
  });

  testWidgets('the three walks, on the floor', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await workByPointer(tester);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'floor');
  });

  testWidgets('a bench waiting, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await carryAll(tester, [0]);
    expect(state(tester).play.waiting, isTrue);
    await shoot(tester, 'waiting');
  });

  testWidgets('show me naming the tool', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await carryAll(tester, [0]);
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
      'belady-iphone-14.png',
      'first.png',
      'round.png',
      'fourth.png',
      'floor.png',
      'waiting.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
