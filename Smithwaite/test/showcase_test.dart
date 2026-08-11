import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/forge.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every position in them was reached by tapping rings, so nothing in the
/// pictures is a state the game could not reach.
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
    testWidgets('the bench on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'bench-${phone.key}');
    });

    testWidgets('a puzzle part worked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      for (var go = 0; go < 6; go++) {
        await move(tester, state(tester).play.next!);
      }
      await shoot(tester, 'working-${phone.key}');
    });

    testWidgets('one freed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await freeItAll(tester);
      expect(state(tester).play.isFree, isTrue);
      await shoot(tester, 'freed-${phone.key}');
    });
  }

  testWidgets('the figures over the rings', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    for (var go = 0; go < 4; go++) {
      await move(tester, state(tester).play.next!);
    }
    await press(tester, 'Why');
    expect(state(tester).showCount, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('the tangle looking nearly done', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'tangle');
  });

  testWidgets('the backwards move called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await move(tester, state(tester).play.next!);
    await move(tester, state(tester).play.next!);
    final play = state(tester).play;
    final wrong = [
      for (var ring = 0; ring < play.puzzle.rings; ring++)
        if (play.mayMove(ring) && ring != play.next) ring,
    ].single;
    await move(tester, wrong);
    expect(state(tester).saying, contains('goes backwards'));
    await shoot(tester, 'costly');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'bench-iphone-14.png',
      'working-iphone-14.png',
      'freed-iphone-14.png',
      'why.png',
      'tangle.png',
      'costly.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
