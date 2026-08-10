import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treblesway/ui/app.dart';

import 'support/ring.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every row in them was rung by tapping changes, so nothing in the pictures
/// is a chamber the game could not reach.
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
        child: TrebleswayApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the towers on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'towers-${phone.key}');
    });

    testWidgets('a peal part rung on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      for (var pull = 0; pull < 7; pull++) {
        await ring(tester, state(tester).play.next!.name);
      }
      await shoot(tester, 'ringing-${phone.key}');
    });

    testWidgets('one come round on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await ringItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'round-${phone.key}');
    });
  }

  testWidgets('the split tower explaining itself', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('a stranded peal', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    var guard = 0;
    while (state(tester).play.canStillRing && guard++ < 30) {
      final play = state(tester).play;
      await ring(tester,
          play.tower.changes.firstWhere(play.mayRing).name);
    }
    expect(state(tester).play.canStillRing, isFalse);
    await shoot(tester, 'stranded');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'towers-iphone-14.png',
      'ringing-iphone-14.png',
      'round-iphone-14.png',
      'why.png',
      'stranded.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
