import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every dial in them was turned, so nothing in the pictures is a
/// pair of tiles the game could not reach.
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
    testWidgets('the holt on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'holt-${phone.key}');
    });

    testWidgets('the great prime paid on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await payByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'greatprime-${phone.key}');
    });
  }

  testWidgets('the five paid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'slate +');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('the three and four paid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    for (var turn = 0; turn < 2; turn++) {
      await press(tester, 'copper +');
    }
    for (var turn = 0; turn < 3; turn++) {
      await press(tester, 'slate +');
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeandfour');
  });

  testWidgets('the half hundred paid by the twins', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    for (var turn = 0; turn < 4; turn++) {
      await press(tester, 'copper +');
      await press(tester, 'slate +');
    }
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.a, state(tester).play.b), (5, 5));
    await shoot(tester, 'halfhundred');
  });

  testWidgets('a hoard overpaid, the sum gone red', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    // Slate alone: 5, 10, 17, 26, and never 25 on the way.
    for (var turn = 0; turn < 4; turn++) {
      await press(tester, 'slate +');
    }
    expect(state(tester).play.paid, 26);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'overpaid');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the forty-three admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Dial to the nearest misses first, then dither out the
    // clock: the sum lands all round the hoard, never on it.
    for (var turn = 0; turn < 4; turn++) {
      await press(tester, 'copper +');
    }
    for (var turn = 0; turn < 4; turn++) {
      await press(tester, 'slate +');
    }
    for (var dither = 0; dither < 4; dither++) {
      await press(tester, 'slate −');
      await press(tester, 'slate +');
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fortythree');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'holt-iphone-14.png',
      'greatprime-iphone-14.png',
      'five.png',
      'threeandfour.png',
      'halfhundred.png',
      'overpaid.png',
      'showme.png',
      'why.png',
      'fortythree.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
