import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every lantern in them was tapped, so nothing in the pictures is a
/// mere the game could not reach.
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

    testWidgets('the six lights still on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      // The beehive.
      await lightAll(tester, [(1, 1), (2, 1), (0, 2), (3, 2), (1, 3), (2, 3)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'sixlights-${phone.key}');
    });
  }

  testWidgets('the four lights still, the block', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await lightAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourlights');
  });

  testWidgets('the five lights still, the boat', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lightAll(tester, [(2, 1), (1, 2), (3, 2), (2, 3), (3, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fivelights');
  });

  testWidgets('the seven lights still', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await lightByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sevenlights');
  });

  testWidgets('a mere mid-lighting, births and deaths shown', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await lightAll(tester, [(1, 1), (2, 1), (3, 1), (2, 3)]);
    expect(state(tester).play.births, isNotEmpty);
    expect(state(tester).play.deaths, isNotEmpty);
    await shoot(tester, 'midlighting');
  });

  testWidgets('show me ringing a spot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three lights admitted, the fourth corner ringed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lightAll(tester, [(1, 1), (2, 1), (1, 2)]);
    for (var dither = 0; dither < 4; dither++) {
      await lightAll(tester, [(1, 2), (1, 2)]);
    }
    expect(state(tester).play.moves, 11);
    expect(state(tester).play.births, {(2, 2)});
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threelights');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'sixlights-iphone-14.png',
      'fourlights.png',
      'fivelights.png',
      'sevenlights.png',
      'midlighting.png',
      'showme.png',
      'why.png',
      'threelights.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
