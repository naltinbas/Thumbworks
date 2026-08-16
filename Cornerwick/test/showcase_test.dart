import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/boardland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every peg in them was set by a tap, so nothing in the pictures is a
/// four the game could not reach.
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

    testWidgets('the square on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await setPegs(tester, [(1, 1), (3, 1), (3, 3), (1, 3)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'square-${phone.key}');
    });
  }

  testWidgets('the whole centres', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setPegs(tester, [(0, 0), (4, 0), (4, 4), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'whole');
  });

  testWidgets('the meeting peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'meeting');
  });

  testWidgets('the fives', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(0, 0), (1, 0), (3, 1), (1, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fives');
  });

  testWidgets('midway, two pegs set, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await setPegs(tester, [(1, 1), (3, 1)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the peg', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapPeg(tester, (2, 2));
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the skew cross admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPegs(tester, [(0, 0), (3, 1), (4, 4), (1, 3)]);
    await tapPeg(tester, (1, 3));
    await tapPeg(tester, (2, 3));
    await tapPeg(tester, (2, 3));
    await tapPeg(tester, (0, 4));
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'skew');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'square-iphone-14.png',
      'whole.png',
      'meeting.png',
      'fives.png',
      'midway.png',
      'showme.png',
      'why.png',
      'skew.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
