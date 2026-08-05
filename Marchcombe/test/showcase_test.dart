import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marchcombe/ui/app.dart';

import 'support/dye.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every dye on them was put there by tapping a field, so nothing in the
/// pictures is a map the game could not reach.
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
        child: MarchcombeApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the estates on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'estates-${phone.key}');
    });

    testWidgets('a map part painted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var step = 0; step < 6; step++) {
        final next = state(tester).play.next!;
        await paint(tester, next.$1, next.$2);
      }
      await shoot(tester, 'painting-${phone.key}');
    });

    testWidgets('one that is painted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      await paintItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'painted-${phone.key}');
    });
  }

  testWidgets('being shown why it takes what it takes', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).showRing, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('two fields the same across a hedge', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    final land = state(tester).play.land;
    var walk = state(tester).play;
    for (var step = 0; step < 5; step++) {
      final next = walk.next!;
      await paint(tester, next.$1, next.$2);
      walk = state(tester).play;
    }
    // Put a dye on a field that one of its neighbours already has.
    final clash = land.hedges.firstWhere(
      (pair) => walk.dyeOf(pair.$1) >= 0 && walk.dyeOf(pair.$2) < 0,
    );
    await paint(tester, clash.$2, walk.dyeOf(clash.$1));
    expect(state(tester).play.clashes, isNotEmpty);
    await shoot(tester, 'clash');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'estates-iphone-14.png',
      'painting-iphone-14.png',
      'painted-iphone-14.png',
      'why.png',
      'clash.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
