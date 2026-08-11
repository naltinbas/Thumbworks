import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/shunt.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every shunt in them was tapped, so nothing in the pictures is a tray
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
    testWidgets('the trays on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'trays-${phone.key}');
    });

    testWidgets('the round of eight part-shunted on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await slide(tester, state(tester).play.next!);
      await slide(tester, state(tester).play.next!);
      await slide(tester, state(tester).play.next!);
      await shoot(tester, 'shunting-${phone.key}');
    });

    testWidgets('a tray home on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await shuntItHome(tester);
      expect(state(tester).play.isHome, isTrue);
      await shoot(tester, 'home-${phone.key}');
    });
  }

  testWidgets('the long way round asked why', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the swindle with its pair rimmed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    expect(state(tester).swindled, isTrue);
    await shoot(tester, 'swindle');
  });

  testWidgets('a wandering shunt called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await slide(tester, 5);
    await shoot(tester, 'wandered');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'trays-iphone-14.png',
      'shunting-iphone-14.png',
      'home-iphone-14.png',
      'why.png',
      'swindle.png',
      'wandered.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
