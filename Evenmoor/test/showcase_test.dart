import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moorland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every peg in them was set by a tap, so nothing in the pictures is
/// a moor the game could not reach.
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

    testWidgets('the four apart landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setPegs(tester, [(0, 0), (1, 0), (0, 1), (1, 1)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fourapart-${phone.key}');
    });
  }

  testWidgets('the three together landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setPegs(tester, [(1, 1), (3, 1), (3, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threetogether');
  });

  testWidgets('the one halfway landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setPegs(tester, [(0, 0), (3, 0), (0, 3), (3, 3), (4, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onehalfway');
  });

  testWidgets('the ten landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(0, 0), (4, 0), (2, 2), (0, 4), (4, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ten');
  });

  testWidgets('a moor mid-pegging, two posts landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(0, 0), (2, 1), (4, 0), (2, 4)]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midpegging');
  });

  testWidgets('show me ringing a hole', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPegs(tester, [(0, 0), (2, 0)]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the five apart admitted, one post landed among four kinds',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPegs(tester, [(0, 0), (1, 0), (0, 1), (1, 1), (4, 4)]);
    for (var dither = 0; dither < 4; dither++) {
      await setPegs(tester, [(4, 4), (4, 4)]);
    }
    expect(state(tester).play.moves, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'fiveapart');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'fourapart-iphone-14.png',
      'threetogether.png',
      'onehalfway.png',
      'ten.png',
      'midpegging.png',
      'showme.png',
      'why.png',
      'fiveapart.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
