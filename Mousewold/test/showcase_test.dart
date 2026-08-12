import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/chase.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every chase in them was stepped post by post, so nothing in the
/// pictures is a standing the game could not reach.
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
    testWidgets('the grounds on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'grounds-${phone.key}');
    });

    testWidgets('the old oak mid-chase on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      await tapPost(tester, state(tester).play.next!);
      await shoot(tester, 'chasing-${phone.key}');
    });

    testWidgets('a mouse cornered on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await chaseIt(tester);
      await shoot(tester, 'cornered-${phone.key}');
    });
  }

  testWidgets('the folding numbered in gold', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'folding');
  });

  testWidgets('a step pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the ring fence holding its lead', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 8; round++) {
      final play = state(tester).play;
      await tapPost(
          tester,
          play.rules.beside[play.cat]
              .firstWhere((post) => post != play.mouse));
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'ringfence');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'grounds-iphone-14.png',
      'chasing-iphone-14.png',
      'cornered-iphone-14.png',
      'folding.png',
      'pointed.png',
      'ringfence.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
