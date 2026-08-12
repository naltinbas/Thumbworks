import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/web.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every thread in them was tapped, so nothing in the pictures is a
/// weave the game could not reach.
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
    testWidgets('the webs on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'webs-${phone.key}');
    });

    testWidgets('the six posts mid-weave on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      for (var round = 0; round < 3; round++) {
        await tapThread(tester, state(tester).play.next!);
      }
      await shoot(tester, 'weaving-${phone.key}');
    });

    testWidgets('the web holding on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await weaveItOut(tester);
      expect(state(tester).play.isDrawn, isTrue);
      await shoot(tester, 'held-${phone.key}');
    });
  }

  testWidgets('a thread pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNot(-1));
    await shoot(tester, 'pointed');
  });

  testWidgets('the six posts won, house triangle bold',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await weaveItOut(tester);
    expect(state(tester).play.playerWon, isTrue);
    await shoot(tester, 'won');
  });

  testWidgets('the first thread closing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await weaveItOut(tester);
    expect(state(tester).play.lostBy, isTrue);
    await shoot(tester, 'firstthread');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'webs-iphone-14.png',
      'weaving-iphone-14.png',
      'held-iphone-14.png',
      'pointed.png',
      'won.png',
      'firstthread.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
