import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millgreave/moor/moors.dart';

import 'support/fonts.dart';
import 'support/moor.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every mill in them was raised by taps, so nothing in the pictures is a
/// moor the game could not reach.
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
    testWidgets('the moors on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'moors-${phone.key}');
    });

    testWidgets('a moor part set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      for (var mills = 0; mills < 4; mills++) {
        final next = state(tester).play.next!;
        await raise(tester, next.$1, next.$2);
      }
      await shoot(tester, 'raising-${phone.key}');
    });

    testWidgets('one set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setItAll(tester);
      expect(state(tester).play.isSet, isTrue);
      await shoot(tester, 'windproof-${phone.key}');
    });
  }

  testWidgets('the built rows as ghosts', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).showBuilt, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the three mills walking their cases', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'three');
  });

  testWidgets('a stranding mill called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    final play = state(tester).play;
    var strander = (-1, -1);
    for (var row = 0; row < Moors.at(3).size && strander.$1 < 0; row++) {
      if (!play.mayRaise(0, row)) continue;
      if (!play.raise(0, row).canStill) strander = (0, row);
    }
    await raise(tester, strander.$1, strander.$2);
    expect(state(tester).saying, contains('strands'));
    await shoot(tester, 'stranded');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'moors-iphone-14.png',
      'raising-iphone-14.png',
      'windproof-iphone-14.png',
      'why.png',
      'three.png',
      'stranded.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
