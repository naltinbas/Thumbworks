import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/weave.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every comb in them was tapped, so nothing in the pictures is a weave
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
    testWidgets('the meshes on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'meshes-${phone.key}');
    });

    testWidgets('the five part-woven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      for (var comb = 0; comb < 5; comb++) {
        final next = state(tester).play.next!;
        await weave(tester, next.$1, next.$2);
      }
      await shoot(tester, 'weaving-${phone.key}');
    });

    testWidgets('a riddle clean on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await weaveItClean(tester);
      expect(state(tester).play.isClean, isTrue);
      await shoot(tester, 'clean-${phone.key}');
    });
  }

  testWidgets('the foul grist run in beads', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await weave(tester, 0, 1);
    await weave(tester, 2, 3);
    await press(tester, 'Why');
    expect(state(tester).showFoul, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the short weave out of combs', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await weave(tester, 0, 1);
    await weave(tester, 2, 3);
    await weave(tester, 0, 2);
    await weave(tester, 1, 3);
    await press(tester, 'Why');
    await shoot(tester, 'shortweave');
  });

  testWidgets('a comb ghosted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Show me');
    expect(state(tester).ghost, isNotNull);
    await shoot(tester, 'ghosted');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'meshes-iphone-14.png',
      'weaving-iphone-14.png',
      'clean-iphone-14.png',
      'why.png',
      'shortweave.png',
      'ghosted.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
