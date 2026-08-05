import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reelbury/reel/stable.dart';
import 'package:reelbury/ui/app.dart';

import 'support/reel.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every couple in them was made by tapping a name, so nothing in the
/// pictures is a floor the game could not reach.
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
        child: ReelburyApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the rounds on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rounds-${phone.key}');
    });

    testWidgets('a floor part paired on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      final answer = Stable.byAsking(state(tester).round.hall);
      for (var caller = 0; caller < 4; caller++) {
        await pair(tester, caller, answer[caller]);
      }
      await touch(tester, 4, caller: true);
      await shoot(tester, 'pairing-${phone.key}');
    });

    testWidgets('two who would rather swap on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await pairThemWrong(tester);
      expect(state(tester).play.blocking, isNotEmpty);
      await shoot(tester, 'swap-${phone.key}');
    });
  }

  testWidgets('a round that holds', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await pairThemUp(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'holds');
  });

  testWidgets('being shown a couple', (tester) async {
    await show(tester, phones['iphone-14']!, which: 6);
    await press(tester, 'Show me');
    await press(tester, 'Show me');
    await shoot(tester, 'shown');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rounds-iphone-14.png',
      'pairing-iphone-14.png',
      'swap-iphone-14.png',
      'holds.png',
      'shown.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
