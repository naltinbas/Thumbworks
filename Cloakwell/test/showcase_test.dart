import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every swap in them was made by a tap, so nothing in the pictures is
/// a row the game could not reach.
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

    testWidgets('the reverse of four sorted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await sortByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'reverseoffour-${phone.key}');
    });
  }

  testWidgets('the two askew sorted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await swapAll(tester, [0, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoaskew');
  });

  testWidgets('the middle out sorted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await sortByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'middleout');
  });

  testWidgets('the reverse of five sorted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await sortByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'reverseoffive');
  });

  testWidgets('a rail mid-sort, three pairs strung', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await swapAll(tester, [0, 1, 2, 3, 0, 1, 2]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midsort');
  });

  testWidgets('show me ringing a gap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the five swaps admitted, one pair still askew',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await sortByDescents(tester);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fiveswaps');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'reverseoffour-iphone-14.png',
      'twoaskew.png',
      'middleout.png',
      'reverseoffive.png',
      'midsort.png',
      'showme.png',
      'why.png',
      'fiveswaps.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
