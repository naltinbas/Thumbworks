import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/steadland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every knight in them was set by taps, so nothing in the pictures is
/// a board the game could not reach.
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

    testWidgets('the six by six seated on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await setByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'sixbysix-${phone.key}');
    });
  }

  testWidgets('the three by three seated', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapAll(tester, [0, 2, 4, 6, 8]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threebythree');
  });

  testWidgets('the four by four seated', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourbyfour');
  });

  testWidgets('the five by five seated', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fivebyfive');
  });

  testWidgets('a board mid-setting, a clash', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapAll(tester, [0, 6, 12]);
    expect(state(tester).play.clashes, [(0, 6)]);
    await shoot(tester, 'midset');
  });

  testWidgets('show me ringing a square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapAll(tester, [0]);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the nine admitted, two knights attacking',
      (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapAll(tester, [0, 2, 5, 7, 8, 10, 13, 15, 1, 1, 1, 1, 1]);
    expect(state(tester).play.moves, 13);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nine');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'sixbysix-iphone-14.png',
      'threebythree.png',
      'fourbyfour.png',
      'fivebyfive.png',
      'midset.png',
      'showme.png',
      'why.png',
      'nine.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
