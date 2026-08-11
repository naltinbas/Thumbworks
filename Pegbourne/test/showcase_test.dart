import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/code.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every peg in them was tapped, so nothing in the pictures is a table
/// the game could not reach.
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
    testWidgets('the riddles on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'riddles-${phone.key}');
    });

    testWidgets('the scattered four mid-answer on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 1);
      final mend = state(tester).play.next!;
      await setSlot(tester, mend.$1, mend.$2);
      final second = state(tester).play.next!;
      await setSlot(tester, second.$1, second.$2);
      await shoot(tester, 'setting-${phone.key}');
    });

    testWidgets('a riddle answered on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await answerIt(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'answered-${phone.key}');
    });
  }

  testWidgets('a wrong code breaking its rows', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    for (var slot = 0; slot < 4; slot++) {
      await setSlot(tester, slot, 0);
    }
    expect(state(tester).play.broken, isNotEmpty);
    await shoot(tester, 'broken');
  });

  testWidgets('the two minds, an answer in gold', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    expect(state(tester).other, isNotNull);
    await shoot(tester, 'twominds');
  });

  testWidgets('the liar counted out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'liar');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'riddles-iphone-14.png',
      'setting-iphone-14.png',
      'answered-iphone-14.png',
      'broken.png',
      'twominds.png',
      'liar.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
