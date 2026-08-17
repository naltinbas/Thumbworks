import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hedgeland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every hedge in them was built by taps, so nothing in the pictures is
/// a hanging the game could not reach.
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

    testWidgets('the long hedge on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await peelByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'long-${phone.key}');
    });
  }

  testWidgets('the middle post', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setHanging(tester, [2, 3, 3, 4, 5]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'middlepost');
  });

  testWidgets('the even hedge', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setHanging(tester, [2, 2, 2, 2, 6]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'evenhedge');
  });

  testWidgets('the round bush', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setHanging(tester, [2, 2, 2, 2, 2]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'roundbush');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setHanging(tester, [1, 2, 3, 2, 5]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting a dial', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three middles given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setHanging(tester, [1, 2, 2, 3, 6]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothree');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'long-iphone-14.png',
      'middlepost.png',
      'evenhedge.png',
      'roundbush.png',
      'midway.png',
      'showme.png',
      'why.png',
      'nothree.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
