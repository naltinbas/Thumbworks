import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dipthorne/ring/rings.dart';

import 'support/dip.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every ring in them was stood in and counted by taps, so nothing in the
/// pictures is a dip the game could not reach.
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
    testWidgets('the rings on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rings-${phone.key}');
    });

    testWidgets('a dip mid-count on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await stand(tester, Rings.at(2).safe);
      for (var chant = 0; chant < 8; chant++) {
        await press(tester, 'Count');
      }
      await shoot(tester, 'counting-${phone.key}');
    });

    testWidgets('one survived on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await stand(tester, Rings.at(1).safe);
      await countItOut(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'stood-${phone.key}');
    });
  }

  testWidgets('the binary turn explaining a two-beat ring', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    expect(state(tester).showSafe, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the reckoning on a seven-beat rhyme', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'reckoning');
  });

  testWidgets('the rhyme finding somebody else', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await stand(tester, 3);
    await countItOut(tester);
    expect(state(tester).play.won, isFalse);
    await shoot(tester, 'found');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rings-iphone-14.png',
      'counting-iphone-14.png',
      'stood-iphone-14.png',
      'why.png',
      'reckoning.png',
      'found.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
