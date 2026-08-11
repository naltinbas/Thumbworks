import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/floor.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every plank in them was tapped, so nothing in the pictures is a room
/// the game could not reach.
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

  Future<void> show(WidgetTester tester, Size size, {int? which}) =>
      open(tester, which: which, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the rooms on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rooms-${phone.key}');
    });

    testWidgets('the parlour mid-plank on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      for (var step = 0; step < 4; step++) {
        final plank = state(tester).play.next!;
        await layPlank(tester, plank.$1, plank.$2);
      }
      await shoot(tester, 'planking-${phone.key}');
    });

    testWidgets('a floor laid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await floorItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'laid-${phone.key}');
    });
  }

  testWidgets('a cell armed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapCell(tester, 5);
    expect(state(tester).armed, 5);
    await shoot(tester, 'armedcell');
  });

  testWidgets('the colours tinted on the fair clip', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showColours, isTrue);
    await shoot(tester, 'faircolours');
  });

  testWidgets('the clipped parlour counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'clipped');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rooms-iphone-14.png',
      'planking-iphone-14.png',
      'laid-iphone-14.png',
      'armedcell.png',
      'faircolours.png',
      'clipped.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
