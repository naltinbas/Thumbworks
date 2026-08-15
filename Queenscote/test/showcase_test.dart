import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/watchland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every queen in them was set by a tap, so nothing in the pictures is a
/// placing the game could not reach.
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

    testWidgets('the chessboard on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await watchByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'chessboard-${phone.key}');
    });
  }

  testWidgets('the four by four', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, [0, 10]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourbyfour');
  });

  testWidgets('the six by six', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await watchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sixbysix');
  });

  testWidgets('the nearest miss', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setAll(tester, [0, 12, 39, 57]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'nearestmiss');
  });

  testWidgets('midway, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 2);
    await setAll(tester, [27, 36]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midway');
  });

  testWidgets('show me ringing a square', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapSquare(tester, 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the lone queen admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapSquare(tester, 5);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'lonequeen');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'chessboard-iphone-14.png',
      'fourbyfour.png',
      'sixbysix.png',
      'nearestmiss.png',
      'midway.png',
      'showme.png',
      'why.png',
      'lonequeen.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
