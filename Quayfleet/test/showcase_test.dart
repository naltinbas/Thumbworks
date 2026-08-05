import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quayfleet/ui/app.dart';

import 'support/berth.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every ship in the berth in them was put there by tapping her line in the
/// book, so nothing in the pictures is a day the game could not reach.
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
        child: QuayfleetApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the days on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'days-${phone.key}');
    });

    testWidgets('a day part worked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var step = 0; step < 3; step++) {
        await berth(tester, state(tester).play.next!);
      }
      await shoot(tester, 'working-${phone.key}');
    });

    testWidgets('one worked to the end on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 5);
      await workItAll(tester);
      expect(state(tester).play.isMost, isTrue);
      await shoot(tester, 'worked-${phone.key}');
    });
  }

  testWidgets('being shown the hours that settle it', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).showMarks, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a day thrown away on the wrong first ship', (tester) async {
    // The Providence is alongside before anybody and holds the berth until
    // noon. Taking her costs two ships.
    await show(tester, phones['iphone-14']!, which: 1);
    await berth(tester, 0);
    expect(state(tester).play.couldStillGet, lessThan(state(tester).play.most));
    await shoot(tester, 'wasted');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'days-iphone-14.png',
      'working-iphone-14.png',
      'worked-iphone-14.png',
      'why.png',
      'wasted.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
