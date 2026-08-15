import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/partyland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every guest in them was added by a press, so nothing in the pictures
/// is a party the game could not reach.
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

    testWidgets('the even chance on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await gather(tester, 23);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'evenchance-${phone.key}');
    });
  }

  testWidgets('nine in ten', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await gather(tester, 41);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'nineinten');
  });

  testWidgets('ninety-nine in a hundred', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await gatherByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ninetynine');
  });

  testWidgets('the shared month', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await gather(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'month');
  });

  testWidgets('mid-gathering, short of the mark', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await gather(tester, 12);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midgathering');
  });

  testWidgets('show me naming the press', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await gather(tester, 31);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the certain day admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 24; k++) {
      await turn(tester, k.isEven ? 10 : -1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'certainday');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'evenchance-iphone-14.png',
      'nineinten.png',
      'ninetynine.png',
      'month.png',
      'midgathering.png',
      'showme.png',
      'why.png',
      'certainday.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
