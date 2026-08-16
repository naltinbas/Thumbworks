import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every hop in them was made by a tap on the stone, so no crossing in
/// the pictures is one the game could not make.
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

    testWidgets('the hundred ford on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await hopAlong(tester, [3, 5, 7, 13, 23, 43, 83, 113]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'hundred-${phone.key}');
    });
  }

  testWidgets('the twin stones', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await hopAlong(tester, [3, 5]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twins');
  });

  testWidgets('the far bank', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await crossByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'farbank');
  });

  testWidgets('the lonely stone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await hopAlong(tester, [3, 5, 7, 11, 17, 31, 53]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lonely');
  });

  testWidgets('midway across, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 0);
    await hopAlong(tester, [3, 5, 7, 13, 23]);
    expect(state(tester).play.at, 23);
    await shoot(tester, 'midway');
  });

  testWidgets('a stone out of reach, refused', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await hopAlong(tester, [3, 5, 7, 13]);
    await tapStone(tester, 43);
    expect(state(tester).play.at, 13);
    await shoot(tester, 'refused');
  });

  testWidgets('show me naming the stone', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await hopAlong(tester, [3, 5, 7, 11]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the long shallows admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await hopAlong(tester, [3, 5, 7, 13, 23, 43, 53, 59, 61]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'shallows');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'hundred-iphone-14.png',
      'twins.png',
      'farbank.png',
      'lonely.png',
      'midway.png',
      'refused.png',
      'showme.png',
      'why.png',
      'shallows.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
