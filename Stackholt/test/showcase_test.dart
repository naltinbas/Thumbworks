import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holt.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every box in them was turned by its buttons, so nothing in the
/// pictures is a stack the game could not reach.
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
    testWidgets('the holt on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'holt-${phone.key}');
    });

    testWidgets('the two boxes settled on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 0);
      await spin(tester, 1);
      if (!state(tester).play.isDone) {
        await spin(tester, 1);
      }
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'settled-${phone.key}');
    });
  }

  testWidgets('the old four as it opens, clashes ringed',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    expect(state(tester).play.clashes, isNotEmpty);
    await shoot(tester, 'oldfour');
  });

  testWidgets('show me ringing a box', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the quads mid-turn', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await spin(tester, 0);
    await tip(tester, 1);
    await spin(tester, 2);
    await shoot(tester, 'quads');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the red stack admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var turn = 0; turn < 16; turn++) {
      await (turn.isEven
          ? spin(tester, turn % 4)
          : tip(tester, turn % 4));
    }
    await shoot(tester, 'redstack');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'holt-iphone-14.png',
      'settled-iphone-14.png',
      'oldfour.png',
      'showme.png',
      'quads.png',
      'why.png',
      'redstack.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
