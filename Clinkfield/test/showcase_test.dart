import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/feastland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every clink in them was tapped, so nothing in the pictures is a
/// feast the game could not reach.
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
    testWidgets('the field on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'field-${phone.key}');
    });

    testWidgets('the four counts feasted on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await feastByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fourcounts-${phone.key}');
    });
  }

  testWidgets('the one count feasted on the ring', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    final rules = state(tester).play.rules;
    for (var pair = 0; pair < rules.pairs.length; pair++) {
      final (a, b) = rules.pairs[pair];
      if ((b - a == 1) || (a == 0 && b == 4)) {
        await tapWire(tester, pair);
      }
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onecount');
  });

  testWidgets('the two counts feasted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await feastByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twocounts');
  });

  testWidgets('the three of four feasted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await feastByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeoffour');
  });

  testWidgets('a feast mid-clink', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapWire(tester, 0);
    await tapWire(tester, 7);
    expect(state(tester).play.moves, 2);
    await shoot(tester, 'midclink');
  });

  testWidgets('show me ringing a pair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the all different admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // The nearest miss: counts 4, 3, 2, 2, 1, the ceiling of
    // four; dither one clink till the field admits, the
    // tableau still standing.
    for (final pair in [0, 1, 2, 3, 4, 5]) {
      await tapWire(tester, pair);
    }
    for (var dither = 0; dither < 4; dither++) {
      await tapWire(tester, 9);
      await tapWire(tester, 9);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.distinct, 4);
    await shoot(tester, 'alldifferent');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'field-iphone-14.png',
      'fourcounts-iphone-14.png',
      'onecount.png',
      'twocounts.png',
      'threeoffour.png',
      'midclink.png',
      'showme.png',
      'why.png',
      'alldifferent.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
