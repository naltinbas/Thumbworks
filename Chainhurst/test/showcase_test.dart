import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hurst.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every stone in them was tapped, so nothing in the pictures is a
/// field the game could not reach.
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
    testWidgets('the hurst on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hurst-${phone.key}');
    });

    testWidgets('the fewest of five landed on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await setAll(
          tester, const [(0, 2), (1, 2), (2, 2), (3, 2), (2, 0)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fewest-${phone.key}');
    });
  }

  testWidgets('the one chain landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, const [(0, 4), (2, 2), (4, 0)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onechain');
  });

  testWidgets('the three landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the row bar spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setAll(
        tester, const [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]);
    await shoot(tester, 'rowbar');
  });

  testWidgets('show me ringing a crossing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the bare-less field admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setAll(
        tester, const [(0, 0), (1, 0), (2, 0), (3, 0), (0, 1)]);
    for (var touch = 5; touch < 16; touch++) {
      await tapCross(tester, 0, 1);
    }
    await shoot(tester, 'bareless');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hurst-iphone-14.png',
      'fewest-iphone-14.png',
      'onechain.png',
      'three.png',
      'rowbar.png',
      'showme.png',
      'why.png',
      'bareless.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
