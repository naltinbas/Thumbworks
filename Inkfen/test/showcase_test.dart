import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every dip in them was tapped, so nothing in the pictures is an
/// inking the game could not reach.
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
    testWidgets('the fen on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fen-${phone.key}');
    });

    testWidgets('the full four inked on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await inkByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fullfour-${phone.key}');
    });
  }

  testWidgets('the two-ink path inked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapString(tester, 0);
    await dipTo(tester, 1, 2);
    await tapString(tester, 2);
    await dipTo(tester, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twopath');
  });

  testWidgets('the even ring inked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await inkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'evenring');
  });

  testWidgets('the ring mended inked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await inkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'ringmended');
  });

  testWidgets('a clash standing sore', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapString(tester, 0);
    await tapString(tester, 1);
    expect(state(tester).play.clashes, hasLength(1));
    await shoot(tester, 'clash');
  });

  testWidgets('show me ringing a string', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd ring admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Alternate as far as five strings allow: the last string
    // clashes whichever ink it wears, the nearest miss there is.
    await tapString(tester, 0);
    await dipTo(tester, 1, 2);
    await tapString(tester, 2);
    await dipTo(tester, 3, 2);
    await tapString(tester, 4);
    for (var dither = 0; dither < 7; dither++) {
      await tapString(tester, 4);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.inked, 5);
    await shoot(tester, 'oddring');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fen-iphone-14.png',
      'fullfour-iphone-14.png',
      'twopath.png',
      'evenring.png',
      'ringmended.png',
      'clash.png',
      'showme.png',
      'why.png',
      'oddring.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
