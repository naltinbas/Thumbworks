import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/row.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every shelf in them was set by taps, so nothing in the pictures is a row
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
    testWidgets('the shelves on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'shelves-${phone.key}');
    });

    testWidgets('a shelf part set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      for (var pairs = 0; pairs < 3; pairs++) {
        await place(tester, state(tester).play.next!);
      }
      await shoot(tester, 'setting-${phone.key}');
    });

    testWidgets('one set on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setItAll(tester);
      expect(state(tester).play.isSet, isTrue);
      await shoot(tester, 'made-${phone.key}');
    });
  }

  testWidgets('the arithmetic on the five pairs', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showSums, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a stranding placement called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    var called = false;
    var guard = 0;
    while (!called && guard++ < 8) {
      final play = state(tester).play;
      var strander = -1;
      for (var seat = 0; seat < play.level.seats; seat++) {
        if (!play.mayPlace(seat)) continue;
        if (!play.place(seat).canStill) {
          strander = seat;
          break;
        }
      }
      if (strander >= 0) {
        await place(tester, strander);
        called = true;
      } else {
        await place(tester, play.next!);
      }
    }
    expect(state(tester).saying, contains('strands'));
    await shoot(tester, 'stranded');
  });

  testWidgets('the eight pairs mid-thought', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var pairs = 0; pairs < 4; pairs++) {
      await place(tester, state(tester).play.next!);
    }
    await shoot(tester, 'eight');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'shelves-iphone-14.png',
      'setting-iphone-14.png',
      'made-iphone-14.png',
      'why.png',
      'stranded.png',
      'eight.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
