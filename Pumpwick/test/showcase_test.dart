import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/laneland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// On the board shots the pump was rolled a spot at a time by taps on
/// the lane, so no standing pictured is one the game could not reach.
/// The sham shots show the mark, standing with no taps behind it.
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

    testWidgets('the five houses on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await rollTo(tester, 5);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'five-${phone.key}');
    });
  }

  testWidgets('the six houses', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await rollTo(tester, 6);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'six');
  });

  testWidgets('the crowded end', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await rollTo(tester, 9);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'crowded');
  });

  testWidgets('the far cottage', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await rollTo(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'cottage');
  });

  testWidgets('beat the middle, admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await rollTo(tester, 5);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'middle');
  });

  testWidgets('the pump at the wrong end, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await rollTo(tester, 3);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'wrongend');
  });

  testWidgets('show me rolling the pump', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await rollTo(tester, 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'five-iphone-14.png',
      'six.png',
      'crowded.png',
      'cottage.png',
      'middle.png',
      'wrongend.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
