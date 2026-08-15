import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pick in them was made by a tap, so nothing in the pictures is
/// a stall the game could not reach.
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

    testWidgets('D against A on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await tapDie(tester, 3);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'dagainsta-${phone.key}');
    });
  }

  testWidgets('A against B', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapDie(tester, 0);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'aagainstb');
  });

  testWidgets('B against C', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'bagainstc');
  });

  testWidgets('C against D', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await pickByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'cagainstd');
  });

  testWidgets('a losing pick, half and no more', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await tapDie(tester, 1);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'losing');
  });

  testWidgets('show me ringing a die', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the champion admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapAll(tester, [0, 1, 2, 3]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'champion');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'dagainsta-iphone-14.png',
      'aagainstb.png',
      'bagainstc.png',
      'cagainstd.png',
      'losing.png',
      'showme.png',
      'why.png',
      'champion.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
