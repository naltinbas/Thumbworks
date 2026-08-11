import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tour.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every trail in them was ridden by taps, so nothing in the pictures is a
/// round the game could not reach.
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
    testWidgets('the yards on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yards-${phone.key}');
    });

    testWidgets('a round mid-ride on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      for (var jump = 0; jump < 11; jump++) {
        await ride(tester, state(tester).play.next!);
      }
      await shoot(tester, 'riding-${phone.key}');
    });

    testWidgets('one ridden on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await rideItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ridden-${phone.key}');
    });
  }

  testWidgets('the grasses tallied at the wrong gate', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).showColours, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the cross paddocks owning the search', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    await shoot(tester, 'cross');
  });

  testWidgets('the full round home again', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await rideItAll(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'home');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yards-iphone-14.png',
      'riding-iphone-14.png',
      'ridden-iphone-14.png',
      'why.png',
      'cross.png',
      'home.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
