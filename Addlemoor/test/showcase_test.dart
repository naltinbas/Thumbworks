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
/// Every stone in them was repainted by taps, so nothing in the
/// pictures is a moor the game could not reach.
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

  Future<void> paintByPointer(WidgetTester tester,
      {int guard = 40}) async {
    var round = 0;
    while (!state(tester).play.isDone && round++ < guard) {
      await press(tester, 'Show me');
      final (stone, paint) = state(tester).pointing!;
      await paintTo(tester, stone, paint);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the moorland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'moorland-${phone.key}');
    });

    testWidgets('the thirteen painted on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await paintByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'thirteen-${phone.key}');
    });
  }

  testWidgets('the four painted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await paintAll(tester, const [0, 1, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('a bad sum ringed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapStone(tester, 5);
    expect(state(tester).play.badSums, isNotEmpty);
    await shoot(tester, 'badsum');
  });

  testWidgets('the eight mid-painting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await paintAll(tester, const [0, 1, 1, 0]);
    await shoot(tester, 'midpaint');
  });

  testWidgets('show me pointing a stone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fourteenth admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var repaint = 0; repaint < 12; repaint++) {
      await tapStone(tester, 1 + repaint % 14);
    }
    await shoot(tester, 'fourteenth');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'moorland-iphone-14.png',
      'thirteen-iphone-14.png',
      'four.png',
      'badsum.png',
      'midpaint.png',
      'showme.png',
      'why.png',
      'fourteenth.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
