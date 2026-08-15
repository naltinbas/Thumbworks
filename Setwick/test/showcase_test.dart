import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/setland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pair in them was tapped, so nothing in the pictures is a
/// set the game could not reach.
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

    testWidgets('the seventeen paired off on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await pairByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.moves, 7);
      await shoot(tester, 'seventeen-${phone.key}');
    });
  }

  testWidgets('the seven paired off by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await pair(tester, 2, 4);
    await pair(tester, 3, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'seven');
  });

  testWidgets('the eleven paired off by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await pair(tester, 2, 6);
    await pair(tester, 3, 4);
    await pair(tester, 5, 9);
    await pair(tester, 7, 8);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eleven');
  });

  testWidgets('the thirteen paired off', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pairByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirteen');
  });

  testWidgets('a set mid-pairing, one sour thread and a pick', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pair(tester, 2, 7);
    await pair(tester, 3, 5);
    await tapDancer(tester, 4);
    expect(state(tester).play.picked, 4);
    expect(state(tester).play.sour, [(3, 5)]);
    await shoot(tester, 'midpair');
  });

  testWidgets('show me ringing a pair', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the set of nine admitted, 3 and 6 sour', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await pair(tester, 2, 5);
    await pair(tester, 4, 7);
    await pair(tester, 3, 6);
    for (var dither = 0; dither < 3; dither++) {
      await tapDancer(tester, 3);
      await pair(tester, 3, 6);
    }
    expect(state(tester).play.moves, 9);
    expect(state(tester).play.sour, [(3, 6)]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nine');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'seventeen-iphone-14.png',
      'seven.png',
      'eleven.png',
      'thirteen.png',
      'midpair.png',
      'showme.png',
      'why.png',
      'nine.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
