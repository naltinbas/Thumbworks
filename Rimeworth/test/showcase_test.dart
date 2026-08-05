import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rimeworth/ui/app.dart';

import 'support/round.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every lane salted in them was salted by tapping, so nothing in the pictures
/// is a parish the game could not reach.
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
        child: RimeworthApp(key: ValueKey(opened++), opensAt: which),
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

    testWidgets('a parish part salted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      for (var step = 0; step < 9; step++) {
        await drive(tester, state(tester).play.next!);
      }
      await shoot(tester, 'salting-${phone.key}');
    });

    testWidgets('one that is finished on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await saltItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'salted-${phone.key}');
    });
  }

  testWidgets('being told why it takes what it takes', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    expect(state(tester).showOdd, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a run thrown away by setting off in the wrong place',
      (tester) async {
    // Gable Row takes one run, and it has to set off at one of the two
    // junctions with three lanes on them. This one sets off at the gable.
    await show(tester, phones['iphone-14']!, which: 1);
    await drive(tester, 4);
    await drive(tester, 2);
    expect(state(tester).play.couldFinishIn, 2);
    await shoot(tester, 'wasted');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'parishes-iphone-14.png',
      'salting-iphone-14.png',
      'salted-iphone-14.png',
      'why.png',
      'wasted.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
