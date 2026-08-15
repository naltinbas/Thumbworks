import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/gableland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every side in them was set by taps, so nothing in the pictures is a
/// gable the game could not reach.
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
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the uneven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await frameByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'uneven-${phone.key}');
    });
  }

  testWidgets('the right angle', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await turn(tester, 'third', -1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'rightangle');
  });

  testWidgets('the twelve', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setSides(tester, 5, 5, 8);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twelve');
  });

  testWidgets('the two alike', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setSides(tester, 10, 13, 13);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoalike');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setSides(tester, 4, 6, 8);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three odds admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setSides(tester, 7, 9, 11);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threeodds');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'uneven-iphone-14.png',
      'rightangle.png',
      'twelve.png',
      'twoalike.png',
      'midway.png',
      'showme.png',
      'why.png',
      'threeodds.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
