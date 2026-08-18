import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yokeland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every ox in them was changed over a tap at a time, so nothing in the
/// pictures is a team the game could not reach.
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

  const dead = <(int, int)>[(0, 1), (1, 2), (2, 3), (3, 4), (0, 4), (0, 2)];

  for (final phone in phones.entries) {
    testWidgets('the yard on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'yard-${phone.key}');
    });

    testWidgets('the best team on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await yokeByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'best-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    expect(state(tester).play.swaps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the middling pull yoked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await yokeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'middling');
  });

  testWidgets('the strong pull yoked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await yokeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'strong');
  });

  testWidgets('a place in hand, part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await swap(tester, 0, 4);
    await tapPlace(tester, 1);
    expect(state(tester).play.held, 1);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming two places', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('past the best given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final pair in dead) {
      if (state(tester).play.gaveUp) break;
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothingharder');
  });

  testWidgets('past the best given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final pair in dead) {
      if (state(tester).play.gaveUp) break;
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothingharder-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'yard-iphone-14.png',
      'best-iphone-14.png',
      'opening.png',
      'middling.png',
      'strong.png',
      'midway.png',
      'showme.png',
      'why.png',
      'nothingharder.png',
      'nothingharder-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
