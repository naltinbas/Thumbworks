import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yard.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every bale in them was set down by tapping the yard, so nothing in the
/// pictures is a morning the game could not reach.
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
    testWidgets('the deals on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'deals-${phone.key}');
    });

    testWidgets('a morning part played on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      for (var bale = 0; bale < 9; bale++) {
        await put(tester, state(tester).play.next!);
      }
      await shoot(tester, 'piling-${phone.key}');
    });

    testWidgets('one done on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await pileItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'piled-${phone.key}');
    });
  }

  testWidgets('the thread through a part-played morning', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    for (var bale = 0; bale < 6; bale++) {
      await put(tester, state(tester).play.next!);
    }
    await press(tester, 'Why');
    expect(state(tester).showThread, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a costly placement called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    for (final slot in costing(state(tester).play)!) {
      await put(tester, slot);
    }
    expect(state(tester).saying, contains('more than'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'deals-iphone-14.png',
      'piling-iphone-14.png',
      'piled-iphone-14.png',
      'why.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
