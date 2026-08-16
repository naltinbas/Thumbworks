import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lanternland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every setting in them was reached by the dials, so nothing in the
/// pictures is a setting the game could not reach.
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

  const triangle = [(1, 0), (0, 1), (-1, -1)];

  for (final phone in phones.entries) {
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the whole meets on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setPegs(tester, [(-2, -2), (0, -2), (-2, 1)]);
      await setCasts(tester, [-1, 3, 2]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'whole-${phone.key}');
    });
  }

  testWidgets('the far line', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setPegs(tester, triangle);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'far');
  });

  testWidgets('the level axis', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setPegs(tester, [(-2, -2), (-1, -2), (-2, -1)]);
    await setCasts(tester, [-2, -2, -1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'level');
  });

  testWidgets('the axis through the lantern', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(-2, -2), (-1, -2), (-2, -1)]);
    await setCasts(tester, [-1, -2, -2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lantern');
  });

  testWidgets('midway, the casts uneven, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await setPegs(tester, triangle);
    await setCasts(tester, [2, 3, -1]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the crooked axis admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPegs(tester, triangle);
    await stepCast(tester, 0, 1);
    await stepCast(tester, 1, 1);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'crooked');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'whole-iphone-14.png',
      'far.png',
      'level.png',
      'lantern.png',
      'midway.png',
      'showme.png',
      'why.png',
      'crooked.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
