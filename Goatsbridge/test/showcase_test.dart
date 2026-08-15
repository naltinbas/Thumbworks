import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stallland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every dial in them was set by a press, so nothing in the pictures is
/// a stall the game could not reach.
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

    testWidgets('two in three on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await set(tester, 'policy');
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twointhree-${phone.key}');
    });
  }

  testWidgets('three in four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setStall(tester, 4, 2, true);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threeinfour');
  });

  testWidgets('better than even, ten doors', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setStall(tester, 10, 8, true);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'betterthaneven');
  });

  testWidgets('the least gain', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'leastgain');
  });

  testWidgets('mid-setting, five doors staying', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setStall(tester, 5, 2, false);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midsetting');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await set(tester, 'doors+');
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the stay admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 24; k++) {
      await set(tester, k.isEven ? 'doors+' : 'doors-');
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'stay');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twointhree-iphone-14.png',
      'threeinfour.png',
      'betterthaneven.png',
      'leastgain.png',
      'midsetting.png',
      'showme.png',
      'why.png',
      'stay.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
