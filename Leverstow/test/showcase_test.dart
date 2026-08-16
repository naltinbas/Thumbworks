import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leverland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every lever turned in them was turned by a tap on its slot, and every
/// slot added by the button, so no loop in the pictures is one the game
/// could not build.
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

    testWidgets('the famous loop on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await buildLoop(tester, 'ABB');
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'famous-${phone.key}');
    });
  }

  testWidgets('the climb', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await loopByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'climb');
  });

  testWidgets('the best loop', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await buildLoop(tester, 'BBABA');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'best');
  });

  testWidgets('the slower four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await buildLoop(tester, 'AABB');
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'four');
  });

  testWidgets('one lever forever, admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapSlot(tester, 0);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'onelever');
  });

  testWidgets('the flat alternation, on the small phone', (tester) async {
    // On the famous ask, since ABAB is stepped through on the way and
    // the climb ask would land before it got there.
    await show(tester, phones['iphone-se']!, which: 1);
    await buildLoop(tester, 'ABAB');
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'flat');
  });

  testWidgets('show me naming the tap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await buildLoop(tester, 'ABAA');
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
      'famous-iphone-14.png',
      'climb.png',
      'best.png',
      'four.png',
      'onelever.png',
      'flat.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
