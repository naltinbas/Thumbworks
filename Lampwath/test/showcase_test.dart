import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lampwath/ui/app.dart';

import 'support/wath.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every crossing in them was made by picking walkers and sending them over,
/// so nothing in the pictures is a night the game could not reach.
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
        child: LampwathApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the bridges on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'bridges-${phone.key}');
    });

    testWidgets('a night part way on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      final party = state(tester).play.next!;
      for (var walker = 0; walker < 4; walker++) {
        if ((party & (1 << walker)) != 0) await pick(tester, walker);
      }
      await crossNow(tester);
      await press(tester, 'Show me');
      await shoot(tester, 'crossing-${phone.key}');
    });

    testWidgets('one crossed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await crossItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'crossed-${phone.key}');
    });
  }

  testWidgets('being told the trade', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('two picked, waiting to cross', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pick(tester, 2);
    await pick(tester, 3);
    expect(state(tester).play.chosenCount, 2);
    await shoot(tester, 'picked');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'bridges-iphone-14.png',
      'crossing-iphone-14.png',
      'crossed-iphone-14.png',
      'why.png',
      'picked.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
