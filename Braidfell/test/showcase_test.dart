import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/braid.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every yard in them was braided pair by pair, so nothing in the
/// pictures is a skein the game could not reach.
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

    testWidgets('the primes mid-braid on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      final (one, two) = state(tester).play.lightest!;
      await tapBundle(tester, one);
      await tapBundle(tester, two);
      await tapBundle(tester, 0);
      await shoot(tester, 'braiding-${phone.key}');
    });

    testWidgets('an asking met on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await braidIt(tester);
      await shoot(tester, 'met-${phone.key}');
    });
  }

  testWidgets('the two lightest pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the sweep spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fifty-nine missed at its cheapest',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await braidIt(tester);
    expect(state(tester).play.met, isFalse);
    await shoot(tester, 'fiftynine');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yards-iphone-14.png',
      'braiding-iphone-14.png',
      'met-iphone-14.png',
      'pointed.png',
      'why.png',
      'fiftynine.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
