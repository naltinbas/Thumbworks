import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wayland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every arrow turned in them was turned by a tap on that street, so no
/// village in the pictures is pointed a way the game could not point
/// it.
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

    testWidgets('the green on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await pointAllByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'green-${phone.key}');
    });
  }

  testWidgets('the square, going round', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await turnAll(tester, [2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'square');
  });

  testWidgets('the house', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pointAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'house');
  });

  testWidgets('the two rings', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await pointAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'rings');
  });

  testWidgets('the toll lane admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await turnAll(tester, [6, 0, 1, 2, 3, 4, 5]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'toll');
  });

  testWidgets('midway through the green, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await turnAll(tester, [3, 4]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the street', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await turnAll(tester, [2]);
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
      'green-iphone-14.png',
      'square.png',
      'house.png',
      'rings.png',
      'toll.png',
      'midway.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
