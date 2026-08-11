import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/quay.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every round in them was dealt a known stowing and played by taps, so
/// nothing in the pictures is a quay the game could not show.
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
      open(tester, which: which, dealt: kindStow, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the berths on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'berths-${phone.key}');
    });

    testWidgets('a look part taken on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await look(tester, 0);
      await look(tester, 4);
      await shoot(tester, 'looking-${phone.key}');
    });

    testWidgets('a crew through on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await followItOut(tester);
      expect(state(tester).play.through, isTrue);
      await shoot(tester, 'through-${phone.key}');
    });
  }

  testWidgets('the loops roped over the doors', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    expect(state(tester).showLoops, isTrue);
    await shoot(tester, 'why');
  });

  testWidgets('a cruel stow owned by its ropes', (tester) async {
    await open(tester,
        which: 2,
        dealt: cruelStow,
        screen: phones['iphone-14']! * ratio);
    await press(tester, 'Why');
    await shoot(tester, 'cruel');
  });

  testWidgets('a crew sunk and told why', (tester) async {
    await open(tester,
        which: 2,
        dealt: cruelStow,
        screen: phones['iphone-14']! * ratio);
    await followItOut(tester);
    expect(state(tester).play.found, isFalse);
    await shoot(tester, 'sunk');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'berths-iphone-14.png',
      'looking-iphone-14.png',
      'through-iphone-14.png',
      'why.png',
      'cruel.png',
      'sunk.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
