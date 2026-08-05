import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trodstow/ui/app.dart';

import 'support/link.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every path cut in them was cut by tapping it, so nothing in the pictures is
/// a parish the game could not reach.
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
        child: TrodstowApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the parishes on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'parishes-${phone.key}');
    });

    testWidgets('a parish part joined on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      for (var step = 0; step < 5; step++) {
        await cut(tester, state(tester).play.next!);
      }
      await shoot(tester, 'cutting-${phone.key}');
    });

    testWidgets('one joined up on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await joinItAll(tester);
      expect(state(tester).play.isCheapest, isTrue);
      await shoot(tester, 'joined-${phone.key}');
    });
  }

  testWidgets('being shown the line a path is cheapest across', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Show me');
    await press(tester, 'Why');
    expect(state(tester).marking.thisSide, isNotEmpty);
    await shoot(tester, 'why');
  });

  testWidgets('being shown the loop a path is dearest on', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    final parish = state(tester).play.parish;
    var dearest = 0;
    for (var trod = 0; trod < parish.many; trod++) {
      if (parish[trod].yards > parish[dearest].yards) dearest = trod;
    }
    await cut(tester, dearest);
    await press(tester, 'Why');
    expect(state(tester).marking.loop, isNotEmpty);
    await shoot(tester, 'loop');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'parishes-iphone-14.png',
      'cutting-iphone-14.png',
      'joined-iphone-14.png',
      'why.png',
      'loop.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
