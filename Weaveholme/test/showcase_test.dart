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
/// Every square in them was turned by a tap, so nothing in the pictures
/// is a plaid the game could not reach.
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

    testWidgets('the eight woven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await weaveByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'eight-${phone.key}');
    });
  }

  testWidgets('the two woven', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapAll(tester, [(1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the four woven', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapAll(tester, [(1, 1), (1, 3), (2, 2), (2, 3), (3, 1), (3, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('the eight over six rows woven', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await weaveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eighttworows');
  });

  testWidgets('a plaid mid-weaving, rows off', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapAll(tester, [(4, 0), (4, 1), (5, 2), (6, 3)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midweaving');
  });

  testWidgets('show me ringing a square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapAll(tester, [(1, 1)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the six admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 30; k++) {
      await tapSquare(tester, k % 6, (k ~/ 6) % 6);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'six');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'eight-iphone-14.png',
      'two.png',
      'four.png',
      'eighttworows.png',
      'midweaving.png',
      'showme.png',
      'why.png',
      'six.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
