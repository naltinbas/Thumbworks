import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every hamlet in them was moved by taps, so nothing in the pictures is
/// a green the game could not reach.
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

    testWidgets('the four hamlets on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await moveHamlet(tester, 1, 1, 1);
      await moveHamlet(tester, 3, 1, 2);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'four-${phone.key}');
    });
  }

  testWidgets('the two and the three', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await moveHamlet(tester, 4, 1, 1);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twothree');
  });

  testWidgets('the five less one', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fivelessone');
  });

  testWidgets('the three and the three less one', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'threelessone');
  });

  testWidgets('mid-laying, crossings in rust', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await moveHamlet(tester, 0, 3, 1);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midlaying');
  });

  testWidgets('show me ringing a point', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three and the three admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var k = 0; k < 12; k++) {
      final h = k % 6;
      await moveHamlet(tester, h, 3, h < 3 ? 1 : 2);
      await moveHamlet(tester, h, h % 3, h < 3 ? 0 : 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'threethree');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'four-iphone-14.png',
      'twothree.png',
      'fivelessone.png',
      'threelessone.png',
      'midlaying.png',
      'showme.png',
      'why.png',
      'threethree.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
