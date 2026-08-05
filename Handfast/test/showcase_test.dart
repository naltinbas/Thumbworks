import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handfast/ui/app.dart';

import 'support/hire.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every job given out in them was given out by tapping a cross, so nothing in
/// the pictures is a board the game could not reach.
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
        child: HandfastApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the fairs on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fairs-${phone.key}');
    });

    testWidgets('a board part given out on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var step = 0; step < 4; step++) {
        final next = state(tester).play.next!;
        await tapCell(tester, next.$1, next.$2);
      }
      await shoot(tester, 'giving-${phone.key}');
    });

    testWidgets('one given out to the end on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await giveItAll(tester);
      expect(state(tester).play.isMost, isTrue);
      await shoot(tester, 'given-${phone.key}');
    });
  }

  testWidgets('being shown the jobs with too few hands', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    expect(state(tester).showShort, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a hand who is already taken on', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapCell(tester, 0, 0);
    await tapCell(tester, 4, 0);
    expect(state(tester).saying, contains('already on'));
    await shoot(tester, 'taken');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fairs-iphone-14.png',
      'giving-iphone-14.png',
      'given-iphone-14.png',
      'why.png',
      'taken.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
