import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ham.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every book in them was swapped by taps, so nothing in the
/// pictures is a shelf the game could not reach.
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
    testWidgets('the ham on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'ham-${phone.key}');
    });

    testWidgets('the stair down on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await swap(tester, 0, 3);
      await swap(tester, 1, 2);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'stair-${phone.key}');
    });
  }

  testWidgets('the one step landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await swap(tester, 0, 1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onestep');
  });

  testWidgets('the sixty-six mid-shelving', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await swap(tester, 3, 4);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midshelve');
  });

  testWidgets('a book in hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapPlace(tester, 1);
    await shoot(tester, 'inhand');
  });

  testWidgets('show me pointing a place', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the fourth step admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 12; round++) {
      await swap(tester, 0, 1);
    }
    await shoot(tester, 'fourthstep');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'ham-iphone-14.png',
      'stair-iphone-14.png',
      'onestep.png',
      'midshelve.png',
      'inhand.png',
      'showme.png',
      'why.png',
      'fourthstep.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
