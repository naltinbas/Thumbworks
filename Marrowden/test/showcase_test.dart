import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marrowden/show/rules.dart';

import 'support/fonts.dart';
import 'support/show.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every sitting in them was judged press by press, so nothing in
/// the pictures is a bench the game could not reach.
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

  Future<void> show(
    WidgetTester tester,
    Size size, {
    int? which,
    List<List<int>>? Function(int)? deals,
  }) =>
      open(tester, which: which, deals: deals, screen: size * ratio);

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  List<List<int>>? Function(int) fixed(List<List<int>> deals) =>
      (number) => deals;

  for (final phone in phones.entries) {
    testWidgets('the benches on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'benches-${phone.key}');
    });

    testWidgets('a best-yet up on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2, deals: fixed(const [
        [2, 1, 4, 0, 3, 5],
      ]));
      await press(tester, 'Wave it by');
      await press(tester, 'Wave it by');
      await shoot(tester, 'judging-${phone.key}');
    });

    testWidgets('a sitting landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0, deals: fixed(const [
        [1, 3, 0, 2],
      ]));
      await press(tester, 'Wave it by');
      await press(tester, 'Take it');
      expect(state(tester).play.sittingWon, isTrue);
      await shoot(tester, 'landed-${phone.key}');
    });
  }

  testWidgets('the rule and the sweep spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1, deals: fixed(const [
      [2, 0, 4, 1, 3],
    ]));
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the bench won', (tester) async {
    await show(tester, phones['iphone-14']!,
        which: 0, deals: fixed(Rules.allSittings(4)));
    await judgeIt(tester);
    expect(state(tester).play.benchWon, isTrue);
    await shoot(tester, 'benchwon');
  });

  testWidgets('the sure pick had you', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4, deals: fixed(const [
      [3, 2, 1, 0],
    ]));
    await judgeIt(tester);
    expect(state(tester).play.benchLost, isTrue);
    await shoot(tester, 'surepick');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'benches-iphone-14.png',
      'judging-iphone-14.png',
      'landed-iphone-14.png',
      'why.png',
      'benchwon.png',
      'surepick.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
