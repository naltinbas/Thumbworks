import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/slateland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every mark in them was made by a tap or by the book's answer, so
/// nothing in the pictures is a slate the game could not reach.
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

    testWidgets('the open slate drawn on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await playByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'openslate-${phone.key}');
    });
  }

  testWidgets('the second hand drawn', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await playByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'secondhand');
  });

  testWidgets('the corner trap won', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await playByPointer(tester);
    expect(state(tester).play.won, isTrue);
    await shoot(tester, 'cornertrap');
  });

  testWidgets('the two corners drawn', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await playByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twocorners');
  });

  testWidgets('a slate mid-game, the book ringed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await markAll(tester, [0, 8]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midgame');
  });

  testWidgets('show me ringing a cell', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the cross wins admitted, the slate played out level',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await playByPointerOrFill(tester);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'crosswins');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'openslate-iphone-14.png',
      'secondhand.png',
      'cornertrap.png',
      'twocorners.png',
      'midgame.png',
      'showme.png',
      'why.png',
      'crosswins.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
