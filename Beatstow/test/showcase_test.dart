import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/beatland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every throw in them was laid by taking it off the rack and tapping a
/// beat, so nothing in the pictures is a laying the game could not reach.
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
    testWidgets('the ring on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'ring-${phone.key}');
    });

    testWidgets('the five throws on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await juggleByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'five-${phone.key}');
    });
  }

  testWidgets('an ask as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    expect(state(tester).play.taps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the rest beat juggled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await juggleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'rest');
  });

  testWidgets('the seven juggled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await juggleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'seven');
  });

  testWidgets('part way through, a throw in the hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await lay(tester, 1, 0);
    await lay(tester, 2, 1);
    await takeThrow(tester, 6);
    expect(state(tester).play.held, 6);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a beat', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await takeThrow(tester, state(tester).play.next!.$1!);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the raised throw given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lay(tester, 3, 0);
    await lay(tester, 3, 1);
    await lay(tester, 3, 2);
    await lay(tester, 4, 3);
    for (var k = 0; k < 24; k++) {
      if (state(tester).play.gaveUp) break;
      await jiggle(tester, 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'wontgo');
  });

  testWidgets('the raised throw given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (var k = 0; k < 24; k++) {
      if (state(tester).play.gaveUp) break;
      await jiggle(tester, 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'wontgo-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'ring-iphone-14.png',
      'five-iphone-14.png',
      'opening.png',
      'rest.png',
      'seven.png',
      'midway.png',
      'showme.png',
      'why.png',
      'wontgo.png',
      'wontgo-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
