import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every sack in them was loaded by taps, so nothing in the pictures is
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

    testWidgets('the three carts on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await loadByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'three-${phone.key}');
    });
  }

  testWidgets('the two carts', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await load(tester, [0, 0, 1, 1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('the tight load', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await loadByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'tight');
  });

  testWidgets('where the carrier slips', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await loadByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'slip');
  });

  testWidgets('mid-loading, a cart over', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await load(tester, [0, 0, 1, null, null, null, null, null]);
    expect(state(tester).play.over[0], isTrue);
    await shoot(tester, 'midloading');
  });

  testWidgets('show me ringing a sack', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await load(tester, [0, 1]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the thirty-one admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 40; k++) {
      await tapSack(tester, k % 6);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'thirtyone');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'three-iphone-14.png',
      'two.png',
      'tight.png',
      'slip.png',
      'midloading.png',
      'showme.png',
      'why.png',
      'thirtyone.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
