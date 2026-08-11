import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/walk.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every crossing in them was tapped, so nothing in the pictures is a walk
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
    testWidgets('the towns on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'towns-${phone.key}');
    });

    testWidgets('the envelope part-walked on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      final start = state(tester).play.nextStart!;
      await tapGround(tester, start);
      await tapBridge(tester, state(tester).play.nextBridge!);
      await tapBridge(tester, state(tester).play.nextBridge!);
      await tapBridge(tester, state(tester).play.nextBridge!);
      await shoot(tester, 'walking-${phone.key}');
    });

    testWidgets('a town walked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await walkItAll(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'walked-${phone.key}');
    });
  }

  testWidgets('the seven bridges asked why', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showOdd, isTrue);
    await shoot(tester, 'sevenbridges');
  });

  testWidgets('the eighth bridge walked home', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await walkItAll(tester);
    await shoot(tester, 'eighthbridge');
  });

  testWidgets('a stranded walk called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapGround(tester, 0);
    await tapBridge(tester, 0);
    await tapBridge(tester, 1);
    await tapBridge(tester, 2);
    expect(state(tester).play.stuck, isTrue);
    await shoot(tester, 'stranded');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'towns-iphone-14.png',
      'walking-iphone-14.png',
      'walked-iphone-14.png',
      'sevenbridges.png',
      'eighthbridge.png',
      'stranded.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
