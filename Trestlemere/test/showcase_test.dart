import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tableland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every guest in them was moved there a tap at a time, so nothing in the
/// pictures is a seating the game could not reach.
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

  const dead = <(int, int)>[(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (1, 0)];

  for (final phone in phones.entries) {
    testWidgets('the hall on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'hall-${phone.key}');
    });

    testWidgets('the three sizes on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await seatByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'sizes-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    expect(state(tester).play.moves, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the three tables seated', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'three');
  });

  testWidgets('the three pairs seated', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'pairs');
  });

  testWidgets('a guest up, part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await move(tester, 0, 1);
    await tapGuest(tester, 3);
    expect(state(tester).holding, 3);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming a guest', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the four sizes given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final step in dead) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'notenough');
  });

  testWidgets('the four sizes given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final step in dead) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'notenough-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'hall-iphone-14.png',
      'sizes-iphone-14.png',
      'opening.png',
      'three.png',
      'pairs.png',
      'midway.png',
      'showme.png',
      'why.png',
      'notenough.png',
      'notenough-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
