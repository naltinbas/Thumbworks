import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/cutland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every line in them was set by taps on the field, so nothing in the
/// pictures is a line the game could not reach.
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
    testWidgets('the sham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'sham-${phone.key}');
    });

    testWidgets('the middle cut on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setPegs(tester, [(6, 0), (0, 4)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'middle-${phone.key}');
    });
  }

  testWidgets('the two inside', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setPegs(tester, [(2, 7), (9, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoinside');
  });

  testWidgets('the whole cuts', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setPegs(tester, [(2, 4), (6, 6)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'whole');
  });

  testWidgets('the twice', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(4, 8), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twice');
  });

  testWidgets('midway, a line outside, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await setPegs(tester, [(12, 1), (11, 3)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapPeg(tester, (1, 0));
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three inside admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPegs(tester, [(1, 0), (2, 1)]);
    await tapPeg(tester, (2, 1));
    await tapPeg(tester, (0, 4));
    await tapPeg(tester, (1, 0));
    await tapPeg(tester, (9, 3));
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threeinside');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'middle-iphone-14.png',
      'twoinside.png',
      'whole.png',
      'twice.png',
      'midway.png',
      'showme.png',
      'why.png',
      'threeinside.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
