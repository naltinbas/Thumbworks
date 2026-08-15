import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every year in them was set by taps, so nothing in the pictures is
/// an almanac the game could not reach.
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

    testWidgets('three Fridays on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await setByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'three-${phone.key}');
    });
  }

  testWidgets('one Friday', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await nextDay(tester);
    await nextDay(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'one');
  });

  testWidgets('two Fridays', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'two');
  });

  testWidgets('a Friday in November', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'november');
  });

  testWidgets('a year mid-setting', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await nextDay(tester);
    await toggleLeap(tester);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midsetting');
  });

  testWidgets('show me pointing at February', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('no Friday admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 14; k++) {
      if (k == 6) {
        await toggleLeap(tester);
      } else {
        await nextDay(tester);
      }
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nofriday');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'three-iphone-14.png',
      'one.png',
      'two.png',
      'november.png',
      'midsetting.png',
      'showme.png',
      'why.png',
      'nofriday.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
