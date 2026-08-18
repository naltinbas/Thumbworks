import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/palingland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the
/// game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every paling in them was lifted and slid in a tap at a time, so no
/// picture shows a fence the game could not reach.
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

  const dead = <(int, int)>[(0, 9), (0, 5), (3, 0), (8, 2), (1, 7), (4, 0)];

  for (final phone in phones.entries) {
    testWidgets('the fence line on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fenceline-${phone.key}');
    });

    testWidgets('the short drop landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await fenceByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'shortdrop-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    expect(state(tester).play.moves, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the even fence landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'even');
  });

  testWidgets('the matched fence landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'matched');
  });

  testWidgets('a paling in hand, part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await moveByPointer(tester);
    await moveByPointer(tester);
    await lift(tester, 6);
    expect(state(tester).play.inHand, isNotNull);
    await shoot(tester, 'inhand');
  });

  testWidgets('show me naming a paling', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three and the three given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final step in dead) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'ninetags');
  });

  testWidgets('the three and the three given up, on the small phone',
      (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final step in dead) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'ninetags-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fenceline-iphone-14.png',
      'shortdrop-iphone-14.png',
      'opening.png',
      'even.png',
      'matched.png',
      'inhand.png',
      'showme.png',
      'why.png',
      'ninetags.png',
      'ninetags-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
