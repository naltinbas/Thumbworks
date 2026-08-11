import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tilth.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every sowing in them was tapped, so nothing in the pictures is a board
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
    testWidgets('the tilths on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'tilths-${phone.key}');
    });

    testWidgets('a board part-sown on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await sow(tester, state(tester).play.next!);
      await sow(tester, state(tester).play.next!);
      await shoot(tester, 'sowing-${phone.key}');
    });

    testWidgets('every seed home on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await sowItAllHome(tester);
      expect(state(tester).play.isHome, isTrue);
      await shoot(tester, 'home-${phone.key}');
    });
  }

  testWidgets('the sowable rims and the words', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await sow(tester, state(tester).play.next!);
    await press(tester, 'Why');
    expect(state(tester).showSowable, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the dead furrows', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'dead');
  });

  testWidgets('a sowing that trapped a furrow', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await sow(tester, 3);
    expect(state(tester).play.trapped, isNotEmpty);
    await shoot(tester, 'trapped');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'tilths-iphone-14.png',
      'sowing-iphone-14.png',
      'home-iphone-14.png',
      'why.png',
      'dead.png',
      'trapped.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
