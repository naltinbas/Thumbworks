import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/drive.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every position in them was reached by tapping squares, so nothing in the
/// pictures is a drive the game could not reach.
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
    testWidgets('the fields on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fields-${phone.key}');
    });

    testWidgets('a drive part way on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      final next = state(tester).play.next!;
      await push(tester, next.$1, next.$2);
      await shoot(tester, 'driving-${phone.key}');
    });

    testWidgets('one won on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await winItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'penned-${phone.key}');
    });
  }

  testWidgets('the ladder on the grass', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showRungs, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a wrong push called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await push(tester, 4, 1);
    expect(state(tester).saying, contains('The fee is his now'));
    await shoot(tester, 'costly');
  });

  testWidgets('the hopeless field saying what it is for', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await shoot(tester, 'hopeless');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fields-iphone-14.png',
      'driving-iphone-14.png',
      'penned-iphone-14.png',
      'why.png',
      'costly.png',
      'hopeless.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
