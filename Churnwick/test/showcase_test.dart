import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:churnwick/ui/app.dart';

import 'support/churn.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every drop of milk in them was poured by tapping churns, so nothing in the
/// pictures is a dairy the game could not reach.
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
        child: ChurnwickApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the mornings on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'mornings-${phone.key}');
    });

    testWidgets('a morning part way through on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      for (var step = 0; step < 5; step++) {
        await press(tester, 'Show me');
      }
      await shoot(tester, 'pouring-${phone.key}');
    });

    testWidgets('one measured out on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      await measureItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'measured-${phone.key}');
    });
  }

  testWidgets('being told what a dairy can measure at all', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showSteps, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a churn picked up, waiting to be poured', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fill(tester, 1);
    await tapChurn(tester, 1);
    expect(state(tester).play.holding, 1);
    await shoot(tester, 'holding');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'mornings-iphone-14.png',
      'pouring-iphone-14.png',
      'measured-iphone-14.png',
      'why.png',
      'holding.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
