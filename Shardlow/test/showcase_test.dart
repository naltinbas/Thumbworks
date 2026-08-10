import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shardlow/ui/app.dart';

import 'support/drop.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every shard and every safe rung in them came of a real drop, with the
/// referee answering for real, so nothing in the pictures is a morning the
/// game could not reach.
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
        child: ShardlowApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the yard on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yard-${phone.key}');
    });

    testWidgets('a morning part way on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await drop(tester, state(tester).play.next!);
      await drop(tester, state(tester).play.next!);
      await press(tester, 'Show me');
      await shoot(tester, 'dropping-${phone.key}');
    });

    testWidgets('one settled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await settleItAll(tester);
      expect(state(tester).play.isFewest, isTrue);
      await shoot(tester, 'settled-${phone.key}');
    });
  }

  testWidgets('being shown the counting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 6);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('a broken pot', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await drop(tester, 10);
    expect(state(tester).saying, contains('broke'));
    await shoot(tester, 'shards');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yard-iphone-14.png',
      'dropping-iphone-14.png',
      'settled-iphone-14.png',
      'why.png',
      'shards.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
