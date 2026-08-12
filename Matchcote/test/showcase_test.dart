import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/coteland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pairing in them was tapped, so nothing in the pictures is a
/// cote the game could not reach.
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

  Future<void> pairByPointer(WidgetTester tester) async {
    var guard = 0;
    while (!state(tester).play.isDone && guard++ < 20) {
      await press(tester, 'Show me');
      final (a, b) = state(tester).pointing!;
      await pairUp(tester, (a, b));
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the coteland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'coteland-${phone.key}');
    });

    testWidgets('the six fixed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await pairByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'six-${phone.key}');
    });
  }

  testWidgets('the four fixed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await pairAll(tester, const [
      [(0, 1), (2, 3)],
      [(0, 2), (1, 3)],
      [(0, 3), (1, 2)],
    ]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('the opener given, dim', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await shoot(tester, 'opener');
  });

  testWidgets('a round mid-fill', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await pairUp(tester, (0, 3));
    await pairUp(tester, (1, 4));
    await shoot(tester, 'midfill');
  });

  testWidgets('show me pointing a pair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fifth player admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 4; round++) {
      await pairUp(tester, (0, 1));
      await pairUp(tester, (0, 1));
    }
    await shoot(tester, 'fifthplayer');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'coteland-iphone-14.png',
      'six-iphone-14.png',
      'four.png',
      'opener.png',
      'midfill.png',
      'showme.png',
      'why.png',
      'fifthplayer.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
