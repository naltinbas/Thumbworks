import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hold.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every choice in them was tapped, so nothing in the pictures is a yard
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
    testWidgets('the consignments on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'consignments-${phone.key}');
    });

    testWidgets('ropes part given on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await tapChip(tester, 0, 0);
      await tapChip(tester, 1, 1);
      await tapChip(tester, 1, 1);
      await shoot(tester, 'choosing-${phone.key}');
    });

    testWidgets('a stack standing on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await stackItAll(tester);
      expect(state(tester).play.isStacked, isTrue);
      await shoot(tester, 'standing-${phone.key}');
    });
  }

  testWidgets('the posts and ropes', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapChip(tester, 0, 0);
    await tapChip(tester, 1, 0);
    await press(tester, 'Why');
    expect(state(tester).showRopes, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the short consignment counted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'short');
  });

  testWidgets('a chip pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'pointed');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'consignments-iphone-14.png',
      'choosing-iphone-14.png',
      'standing-iphone-14.png',
      'why.png',
      'short.png',
      'pointed.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
