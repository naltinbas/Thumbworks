import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plaitland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the
/// game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every rope in them was dyed a tap at a time, so no picture shows a
/// painting the game could not reach.
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

  const dead = <int>[0, 1, 2, 3, 0, 1, 2, 3];

  for (final phone in phones.entries) {
    testWidgets('the rope walk on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'ropewalk-${phone.key}');
    });

    testWidgets('the short plait painted on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await paintByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'short-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    expect(state(tester).play.taps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the long plait painted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'long');
  });

  testWidgets('the granny painted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'granny');
  });

  testWidgets('the torus plait painted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'torus');
  });

  testWidgets('a crossing gone wrong, part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await dye(tester, 2);
    await dye(tester, 5);
    expect(state(tester).play.allSound, isFalse);
    await shoot(tester, 'wrong');
  });

  testWidgets('show me naming a rope', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the figure eight given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final arc in dead) {
      if (state(tester).play.gaveUp) break;
      await dye(tester, arc);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'onecolour');
  });

  testWidgets('the figure eight given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final arc in dead) {
      if (state(tester).play.gaveUp) break;
      await dye(tester, arc);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'onecolour-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'ropewalk-iphone-14.png',
      'short-iphone-14.png',
      'opening.png',
      'long.png',
      'granny.png',
      'torus.png',
      'wrong.png',
      'showme.png',
      'why.png',
      'onecolour.png',
      'onecolour-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(15));
  });
}
