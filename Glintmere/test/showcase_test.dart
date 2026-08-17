import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/glintland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every bounce in them was slid there a peg at a time, so nothing in the
/// pictures is a setting the game could not reach.
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
    testWidgets('the mirror on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'mirror-${phone.key}');
    });

    testWidgets('the even angles on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await catchByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'even-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    expect(state(tester).play.slides, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the thirteen caught', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await catchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'thirteen');
  });

  testWidgets('the eleven caught', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await catchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'eleven');
  });

  testWidgets('part way along the glass', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await slideTowards(tester, 12);
    await slideTowards(tester, 12);
    expect(state(tester).play.bounce, 2);
    await shoot(tester, 'midway');
  });

  testWidgets('show me pointing the way', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the nine given up, the board folded open', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 10; k++) {
      if (state(tester).play.gaveUp) break;
      await slideTowards(tester, 12);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'folded');
  });

  testWidgets('the nine given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (var k = 0; k < 10; k++) {
      if (state(tester).play.gaveUp) break;
      await slideTowards(tester, 12);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'folded-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'mirror-iphone-14.png',
      'even-iphone-14.png',
      'opening.png',
      'thirteen.png',
      'eleven.png',
      'midway.png',
      'showme.png',
      'why.png',
      'folded.png',
      'folded-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
