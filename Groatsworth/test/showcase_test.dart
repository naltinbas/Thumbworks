import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groatsworth/ui/app.dart';

import 'support/counter.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every coin on a tray in them was put down by tapping the till, so nothing
/// in the pictures is a counter the game could not reach.
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
        child: GroatsworthApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the counter book on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'book-${phone.key}');
    });

    testWidgets('a round part paid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      for (var step = 0; step < 5; step++) {
        await put(tester, state(tester).play.next!);
      }
      await press(tester, 'Show me');
      await shoot(tester, 'paying-${phone.key}');
    });

    testWidgets('one served on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await payItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'served-${phone.key}');
    });
  }

  testWidgets('being told why the half crown is the wrong coin',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the half crown put down anyway', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await put(tester, 5);
    expect(state(tester).saying, contains('more than the'));
    await shoot(tester, 'wrongcoin');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'book-iphone-14.png',
      'paying-iphone-14.png',
      'served-iphone-14.png',
      'why.png',
      'wrongcoin.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
