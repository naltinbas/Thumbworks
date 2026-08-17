import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/foldland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every whistle on an ask screen was blown by a tap on its button. The
/// fold across the top of the sham shot is the mark, set four whistles
/// into the long fold's call by hand rather than tapped.
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
      await show(tester, phone.value, which: 3);
      await gatherByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nine-${phone.key}');
    });
  }

  testWidgets('the two whistles', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await blowCall(tester, [0, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the three', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await gatherByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the five', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await gatherByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('the turning fold admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await blowCall(tester, [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'turning');
  });

  testWidgets('part way through the nine, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await blowCall(tester, [1, 0, 0, 0]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'partway');
  });

  testWidgets('show me naming the whistle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await blowCall(tester, [0, 1]);
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
      'nine-iphone-14.png',
      'two.png',
      'three.png',
      'five.png',
      'turning.png',
      'partway.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
