import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/charm.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every laying in them was tapped, so nothing in the pictures is a bed
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

  Future<void> show(WidgetTester tester, Size size, {int? which}) =>
      open(tester, which: which, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the charms on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'charms-${phone.key}');
    });

    testWidgets('coins mid-lay on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      for (var step = 0; step < 4; step++) {
        final (cell, coin) = state(tester).play.next!;
        if (coin == null) {
          await tapCell(tester, cell);
        } else {
          await lay(tester, cell, coin);
        }
      }
      await shoot(tester, 'laying-${phone.key}');
    });

    testWidgets('a charm held on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'held-${phone.key}');
    });
  }

  testWidgets('a coin armed over the bed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapTray(tester, 8);
    expect(state(tester).armed, 8);
    await shoot(tester, 'coinarmed');
  });

  testWidgets('a broken line counted red', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await lay(tester, 0, 1);
    await lay(tester, 1, 2);
    await lay(tester, 2, 3);
    await shoot(tester, 'brokenline');
  });

  testWidgets('the heart of one counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'heartofone');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'charms-iphone-14.png',
      'laying-iphone-14.png',
      'held-iphone-14.png',
      'coinarmed.png',
      'brokenline.png',
      'heartofone.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
