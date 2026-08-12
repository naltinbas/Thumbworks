import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every friendship in them was tapped, so nothing in the pictures
/// is a circle the game could not reach.
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
    testWidgets('the holme on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'holme-${phone.key}');
    });

    testWidgets('the seven settled on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await settleByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'seven-${phone.key}');
    });
  }

  testWidgets('the three friends settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    for (var pair = 0; pair < 3; pair++) {
      await tapWire(tester, pair);
    }
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threefriends');
  });

  testWidgets('the given hub settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'givenhub');
  });

  testWidgets('the five settled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('a circle mid-wire', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapWire(tester, 0);
    await tapWire(tester, 4);
    expect(state(tester).play.moves, 2);
    await shoot(tester, 'midwire');
  });

  testWidgets('show me ringing a pair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the even crowd admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // The ring of four: every friend count even, and every
    // neighbouring pair sharing nobody, the nearest miss there is.
    final ring = [(0, 1), (1, 2), (2, 3), (0, 3)];
    for (final pair in ring) {
      await tapWire(
          tester, state(tester).play.rules.pairs.indexOf(pair));
    }
    for (var dither = 0; dither < 4; dither++) {
      final at = state(tester).play.rules.pairs.indexOf((0, 2));
      await tapWire(tester, at);
      await tapWire(tester, at);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'evencrowd');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'holme-iphone-14.png',
      'seven-iphone-14.png',
      'threefriends.png',
      'givenhub.png',
      'five.png',
      'midwire.png',
      'showme.png',
      'why.png',
      'evencrowd.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
