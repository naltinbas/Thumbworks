import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plot.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every mark in them was tapped, so nothing in the pictures is a plot
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
    testWidgets('the plots on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'plots-${phone.key}');
    });

    testWidgets('the well part-shaded on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      for (var step = 0; step < 8; step++) {
        final offer = state(tester).play.next!;
        await mark(tester, offer.$1, offer.$2, shade: offer.$3);
      }
      await shoot(tester, 'shading-${phone.key}');
    });

    testWidgets('a picture standing on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await shadeItHome(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'standing-${phone.key}');
    });
  }

  testWidgets('a deduction pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'pointed');
  });

  testWidgets('the two gardens, the other outlined', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    expect(state(tester).other, isNotNull);
    await shoot(tester, 'gardens');
  });

  testWidgets('the short tally counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await press(tester, 'Why');
    await shoot(tester, 'shorttally');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'plots-iphone-14.png',
      'shading-iphone-14.png',
      'standing-iphone-14.png',
      'pointed.png',
      'gardens.png',
      'shorttally.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
