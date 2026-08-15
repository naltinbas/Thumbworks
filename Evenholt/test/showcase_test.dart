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
/// Every token in them was carried by a tap, so nothing in the
/// pictures is a share the game could not reach.
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

    testWidgets('the sixteen shared on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await shareByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.moves, 8);
      await shoot(tester, 'sixteen-${phone.key}');
    });
  }

  testWidgets('the four shared by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await carry(tester, [2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('the eight shared by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await carry(tester, [2, 3, 5, 8]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eight');
  });

  testWidgets('the dozen shared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'dozen');
  });

  testWidgets('a share mid-deal, sums level and squares not',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await carry(tester, [3, 4, 5, 6]);
    expect(state(tester).play.agreeing, [true, false]);
    await shoot(tester, 'middeal');
  });

  testWidgets('show me ringing a token', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await carry(tester, [2, 3, 5]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the four squared admitted, sums level and squares apart',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await carry(tester, [2, 3]);
    for (var dither = 0; dither < 3; dither++) {
      await carry(tester, [1, 1]);
    }
    expect(state(tester).play.moves, 8);
    expect(state(tester).play.leftTray, [1, 4]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'foursquared');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'sixteen-iphone-14.png',
      'four.png',
      'eight.png',
      'dozen.png',
      'middeal.png',
      'showme.png',
      'why.png',
      'foursquared.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
