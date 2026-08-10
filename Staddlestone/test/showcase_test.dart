import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staddlestone/ui/app.dart';

import 'support/mill.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every stone in them was moved by tapping staddles, so nothing in the
/// pictures is a yard the game could not reach.
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
        child: StaddlestoneApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the yards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yards-${phone.key}');
    });

    testWidgets('a yard part worked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      for (var step = 0; step < 9; step++) {
        final next = state(tester).play.next!;
        await move(tester, next.$1, next.$2);
      }
      await shoot(tester, 'working-${phone.key}');
    });

    testWidgets('one home on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await workItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'home-${phone.key}');
    });
  }

  testWidgets('being told the doubling', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('a stone lifted, waiting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapStaddle(tester, 0);
    expect(state(tester).play.lifted, 0);
    await shoot(tester, 'lifted');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yards-iphone-14.png',
      'working-iphone-14.png',
      'home-iphone-14.png',
      'why.png',
      'lifted.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
