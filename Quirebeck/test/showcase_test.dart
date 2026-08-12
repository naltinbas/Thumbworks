import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/quire.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every stack in them was woven weave by weave, so nothing in the
/// pictures is a state the game could not reach.
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
    testWidgets('the bench on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'bench-${phone.key}');
    });

    testWidgets('the broken stitch mid-weave on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 4);
      await weave(tester, state(tester).play.next!);
      await shoot(tester, 'weaving-${phone.key}');
    });

    testWidgets('a quire bound on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 4);
      await weaveIt(tester);
      await shoot(tester, 'bound-${phone.key}');
    });
  }

  testWidgets('the seat word spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    await shoot(tester, 'seatword');
  });

  testWidgets('a weave pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the turned pair woven out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    for (var round = 0; round < 8; round++) {
      await weave(tester, round.isOdd);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'turnedpair');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'bench-iphone-14.png',
      'weaving-iphone-14.png',
      'bound-iphone-14.png',
      'seatword.png',
      'pointed.png',
      'turnedpair.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
