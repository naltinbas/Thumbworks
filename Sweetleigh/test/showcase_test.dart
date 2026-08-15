import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leighland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every cut in them was tapped, so nothing in the pictures is a
/// share the game could not reach.
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

    testWidgets('the long string shared on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await cutByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'longstring-${phone.key}');
    });
  }

  testWidgets('the one cut by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapGap(tester, 4);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'onecut');
  });

  testWidgets('the two cuts by hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await cutAll(tester, [2, 6]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twocuts');
  });

  testWidgets('the three kinds shared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threekinds');
  });

  testWidgets('a string mid-cut, one cut in the wrong place', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapGap(tester, 3);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midcut');
  });

  testWidgets('show me ringing a gap', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the single cut admitted, the middle cut standing', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapGap(tester, 4);
    for (var dither = 0; dither < 4; dither++) {
      await cutAll(tester, [4, 4]);
    }
    expect(state(tester).play.moves, 9);
    expect(state(tester).play.cuts, [4]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'singlecut');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'longstring-iphone-14.png',
      'onecut.png',
      'twocuts.png',
      'threekinds.png',
      'midcut.png',
      'showme.png',
      'why.png',
      'singlecut.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
