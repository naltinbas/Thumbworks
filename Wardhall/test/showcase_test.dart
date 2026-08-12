import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hall.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every hall in them was warded corner by corner, so nothing in the
/// pictures is a floor the game could not reach.
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
    testWidgets('the halls on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'halls-${phone.key}');
    });

    testWidgets('the comb half-warded on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      final play = state(tester).play;
      await tapCorner(tester, play.nextOf(play.finished!)!);
      await shoot(tester, 'warding-${phone.key}');
    });

    testWidgets('a hall lit on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await lightIt(tester);
      await shoot(tester, 'lit-${phone.key}');
    });
  }

  testWidgets('a corner pointed at', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'pointed');
  });

  testWidgets('the colouring spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the comb short left dark', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapCorner(tester, 0);
    await tapCorner(tester, 1);
    expect(state(tester).play.isOver, isTrue);
    await shoot(tester, 'combshort');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'halls-iphone-14.png',
      'warding-iphone-14.png',
      'lit-iphone-14.png',
      'pointed.png',
      'why.png',
      'combshort.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
