import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/squareland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every setting in them was made by taps on the dials, so nothing in
/// the pictures is a setting the game could not reach.
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

    testWidgets('the two of seven on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await setDials(tester, 7, 3);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'twoofseven-${phone.key}');
    });
  }

  testWidgets('the odd hour', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setDials(tester, 7, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'oddhour');
  });

  testWidgets('the minus one', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setDials(tester, 13, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'minusone');
  });

  testWidgets('the two', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setDials(tester, 23, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setDials(tester, 13, 4);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me naming the dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await turn(tester, 'base', 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the two of eleven admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setDials(tester, 11, 10);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'twoofeleven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'twoofseven-iphone-14.png',
      'oddhour.png',
      'minusone.png',
      'two.png',
      'midway.png',
      'showme.png',
      'why.png',
      'twoofeleven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
