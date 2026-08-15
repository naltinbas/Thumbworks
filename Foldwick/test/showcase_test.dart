import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/foldland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every move in them was tapped, so nothing in the pictures is a
/// plank the game could not reach.
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

    testWidgets('the three and three crossed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await crossByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'threeandthree-${phone.key}');
    });
  }

  testWidgets('the one and one crossed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await moveAll(tester, [0, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oneandone');
  });

  testWidgets('the two and two crossed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await crossByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoandtwo');
  });

  testWidgets('the three and two crossed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await crossByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeandtwo');
  });

  testWidgets('a plank mid-crossing, interleaved', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    for (var i = 0; i < 7; i++) {
      await press(tester, 'Show me');
      await tapPen(tester, state(tester).pointing!);
    }
    expect(state(tester).play.moves, 7);
    await shoot(tester, 'midcrossing');
  });

  testWidgets('show me ringing a pen', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the steps alone admitted, the fold stuck', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await moveAll(tester, [1, 0]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'stepsalone');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'threeandthree-iphone-14.png',
      'oneandone.png',
      'twoandtwo.png',
      'threeandtwo.png',
      'midcrossing.png',
      'showme.png',
      'why.png',
      'stepsalone.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
