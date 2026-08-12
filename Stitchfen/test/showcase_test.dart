import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/sampler.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every stitch in them was flipped by taps, so nothing in the
/// pictures is a row the game could not reach.
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
    testWidgets('the fen on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fen-${phone.key}');
    });

    testWidgets('the eight threaded on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await threadAll(tester, 'RRBBRRBB');
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'eight-${phone.key}');
    });
  }

  testWidgets('ladders called out mid-thread', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await threadAll(tester, 'RRBRRRB');
    expect(state(tester).play.ladders, isNotEmpty);
    await shoot(tester, 'ladders');
  });

  testWidgets('the one way, fixed stitches dim', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await shoot(tester, 'oneway');
  });

  testWidgets('show me pointing a stitch', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the ninth stitch admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var flip = 0; flip < 12; flip++) {
      await tapStitch(tester, flip % 9);
    }
    await shoot(tester, 'ninthstitch');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fen-iphone-14.png',
      'eight-iphone-14.png',
      'ladders.png',
      'oneway.png',
      'showme.png',
      'why.png',
      'ninthstitch.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
