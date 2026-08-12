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
/// Every brick in them was tapped, so nothing in the pictures is a
/// yard the game could not reach.
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
    testWidgets('the yardland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yardland-${phone.key}');
    });

    testWidgets('the sound course landed on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'sound-${phone.key}');
    });
  }

  testWidgets('the four-square landed, seams gold', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    for (var brick = 0; brick < 8; brick++) {
      await brickOver(tester, (brick * 2, brick * 2 + 1));
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'foursquare');
  });

  testWidgets('the one seam landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.seams, hasLength(1));
    await shoot(tester, 'oneseam');
  });

  testWidgets('the seven seams landed, the plain stack',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.seams, hasLength(7));
    await shoot(tester, 'sevenseams');
  });

  testWidgets('a laying mid-course, one cell picked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await brickOver(tester, (0, 6));
    await brickOver(tester, (1, 2));
    await brickOver(tester, (12, 18));
    await tapCell(tester, 8);
    expect(state(tester).play.picked, 8);
    await shoot(tester, 'midcourse');
  });

  testWidgets('show me pointing a brick', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seamless six admitted, bricked and cracked',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // The whole plain stack: eighteen moves, bricked whole, and
    // the seams stand gold where the asking wanted none.
    for (var brick = 0; brick < 18; brick++) {
      await brickOver(tester, (brick * 2, brick * 2 + 1));
    }
    expect(state(tester).play.bricked, isTrue);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'cracked');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yardland-iphone-14.png',
      'sound-iphone-14.png',
      'foursquare.png',
      'oneseam.png',
      'sevenseams.png',
      'midcourse.png',
      'showme.png',
      'why.png',
      'cracked.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
