import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feltmere/hat/levels.dart';

import 'support/fonts.dart';
import 'support/hatland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// On the board shots every cell was set by taps on that cell, so no
/// agreement pictured is one the game could not reach. The sham shots
/// show the mark, standing with no taps behind it.
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

    testWidgets('the six on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await setAgreement(tester, Levels.at(3).aim);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'six-${phone.key}');
    });
  }

  testWidgets('the half', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'half');
  });

  testWidgets('the silent one', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'silent');
  });

  testWidgets('the five', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'five');
  });

  testWidgets('the seven, admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setAgreement(tester, Levels.at(3).aim);
    await setAgreement(tester, const [
      [1, 2, 2, 0],
      [1, 2, 2, 0],
      [1, 2, 2, 0],
    ]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'seven');
  });

  testWidgets('the matching rule, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 3);
    await setAgreement(tester, const [
      [1, 2, 2, 0],
      [1, 2, 2, 0],
      [1, 2, 2, 0],
    ]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'matching');
  });

  testWidgets('show me naming the cell', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapCell(tester, 0, 0);
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
      'six-iphone-14.png',
      'half.png',
      'silent.png',
      'five.png',
      'seven.png',
      'matching.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
