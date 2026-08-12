import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/marshland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every post in them was tapped, so nothing in the pictures is a
/// marsh the game could not reach.
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

  Future<void> setByPointer(WidgetTester tester) async {
    var guard = 0;
    while (!state(tester).play.isDone && guard++ < 16) {
      await press(tester, 'Show me');
      final (x, y) = state(tester).pointing!;
      await tapCross(tester, x, y);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the marshland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'marshland-${phone.key}');
    });

    testWidgets('the one frame standing on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await setByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'oneframe-${phone.key}');
    });
  }

  testWidgets('the crooked four standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, const [(0, 0), (3, 0), (1, 3), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'crookedfour');
  });

  testWidgets('the full five standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fullfive');
  });

  testWidgets('a shared line called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setAll(tester, const [(0, 0), (1, 1), (2, 2)]);
    await shoot(tester, 'sharedline');
  });

  testWidgets('show me ringing a crossing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the frameless five admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var touch = 0; touch < 16; touch++) {
      await tapCross(tester, 0, 0);
    }
    await shoot(tester, 'frameless');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'marshland-iphone-14.png',
      'oneframe-iphone-14.png',
      'crookedfour.png',
      'fullfive.png',
      'sharedline.png',
      'showme.png',
      'why.png',
      'frameless.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
