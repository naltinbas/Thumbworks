import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/post.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every stamp in them was licked on by taps, so nothing in the pictures is
/// a letter the game could not frank.
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
    testWidgets('the letters on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'letters-${phone.key}');
    });

    testWidgets('a letter part stamped on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await lick(tester, false);
      await lick(tester, false);
      await shoot(tester, 'sticking-${phone.key}');
    });

    testWidgets('one paid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await payItAll(tester);
      expect(state(tester).play.isPaid, isTrue);
      await shoot(tester, 'paid-${phone.key}');
    });
  }

  testWidgets('the walk on the unpayable letter', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showWalk, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the walk finding its hit', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'hit');
  });

  testWidgets('a stranding stamp called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await lick(tester, true);
    await lick(tester, true);
    expect(state(tester).saying, contains('stranded'));
    await shoot(tester, 'stranded');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'letters-iphone-14.png',
      'sticking-iphone-14.png',
      'paid-iphone-14.png',
      'why.png',
      'hit.png',
      'stranded.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
