import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/showland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every ballot in them was set by taps, so nothing in the pictures is
/// a show the game could not reach.
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

    testWidgets('the ring on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setBallot(tester, 1, [1, 2, 0]);
      await setBallot(tester, 2, [2, 0, 1]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'ring-${phone.key}');
    });
  }

  testWidgets('the ring of four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await judgeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ringoffour');
  });

  testWidgets('the points betray', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await judgeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'points');
  });

  testWidgets('the modest winner of four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await judgeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'modestfour');
  });

  testWidgets('mid-judging, a winner still', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setBallot(tester, 1, [1, 2, 0]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midjudging');
  });

  testWidgets('show me ringing a pie', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the modest winner admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 24; k++) {
      await tapPie(tester, k % 3, 2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'modest');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'ring-iphone-14.png',
      'ringoffour.png',
      'points.png',
      'modestfour.png',
      'midjudging.png',
      'showme.png',
      'why.png',
      'modest.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
