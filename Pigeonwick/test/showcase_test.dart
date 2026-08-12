import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wick.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every letter in them was posted by taps, so nothing in the
/// pictures is a round the game could not reach.
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
    testWidgets('the wick on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'wick-${phone.key}');
    });

    testWidgets('the forty-four posted on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await postAll(tester, const [1, 0, 3, 4, 2]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fortyfour-${phone.key}');
    });
  }

  testWidgets('a letter in hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await post(tester, 0, 1);
    await tapLetter(tester, 1);
    await shoot(tester, 'inhand');
  });

  testWidgets('a letter home, called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await post(tester, 0, 0);
    await post(tester, 1, 2);
    await shoot(tester, 'home');
  });

  testWidgets('the one home landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await postAll(tester, const [0, 2, 3, 1]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onehome');
  });

  testWidgets('show me pointing a posting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three home admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var posting = 0; posting < 6; posting++) {
      await post(tester, 0, 1);
      await tapHole(tester, 1);
    }
    await shoot(tester, 'threehome');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'wick-iphone-14.png',
      'fortyfour-iphone-14.png',
      'inhand.png',
      'home.png',
      'onehome.png',
      'showme.png',
      'why.png',
      'threehome.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
