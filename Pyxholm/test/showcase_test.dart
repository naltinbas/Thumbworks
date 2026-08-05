import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyxholm/ui/app.dart';

import 'support/assay.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every coin on a pan in them was put there by tapping it, and every beam in
/// them tipped the way it really tips, so nothing in the pictures is a bench
/// the game could not reach.
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

  var opened = 0;

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: PyxholmApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the boxes on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'boxes-${phone.key}');
    });

    testWidgets('a box part settled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      await press(tester, 'Show me');
      await press(tester, 'Weigh');
      await press(tester, 'Show me');
      await shoot(tester, 'weighing-${phone.key}');
    });

    testWidgets('one settled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await settleItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'settled-${phone.key}');
    });
  }

  testWidgets('being told where the number comes from', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('a weighing that threw the fewest away', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await weigh(tester, [0], [1]);
    expect(state(tester).play.couldFinishIn, greaterThan(3));
    await shoot(tester, 'wasted');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'boxes-iphone-14.png',
      'weighing-iphone-14.png',
      'settled-iphone-14.png',
      'why.png',
      'wasted.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
