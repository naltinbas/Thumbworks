import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winnowmere/ui/app.dart';

import 'support/sift.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every comparator in them was put there by tapping two lines, so nothing in
/// the pictures is a network the game could not reach.
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
        child: WinnowmereApp(key: ValueKey(opened++), opensAt: which),
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
    testWidgets('the puzzles on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'puzzles-${phone.key}');
    });

    testWidgets('a network part built on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await put(tester, 0, 1);
      await put(tester, 2, 3);
      await put(tester, 0, 2);
      await shoot(tester, 'building-${phone.key}');
    });

    testWidgets('one that sorts on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await sortItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'sorted-${phone.key}');
    });
  }

  testWidgets('the row it is still getting wrong', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await put(tester, 1, 4);
    expect(state(tester).play.fails, isNotNull);
    await shoot(tester, 'wrong');
  });

  testWidgets('being shown a comparator', (tester) async {
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
      'puzzles-iphone-14.png',
      'building-iphone-14.png',
      'sorted-iphone-14.png',
      'wrong.png',
      'shown.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
