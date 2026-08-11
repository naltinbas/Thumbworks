import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/cloth.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every bench in them was cut by taps, so nothing in the pictures is a
/// standing the game could not reach.
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
    testWidgets('the benches on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'benches-${phone.key}');
    });

    testWidgets('a cut part marked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await markOne(tester);
      await markOne(tester);
      await shoot(tester, 'marking-${phone.key}');
    });

    testWidgets('one held on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await holdItAll(tester);
      expect(state(tester).play.won, isTrue);
      await shoot(tester, 'held-${phone.key}');
    });
  }

  testWidgets('the golden tick on the near run', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showGap, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the golden bench owned', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'golden');
  });

  testWidgets('a wrong cut called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await cut(tester, 1);
    expect(state(tester).saying, contains('the mercer\'s now'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'benches-iphone-14.png',
      'marking-iphone-14.png',
      'held-iphone-14.png',
      'why.png',
      'golden.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
