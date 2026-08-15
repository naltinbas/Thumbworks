import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/buryland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every piece in them was laid by taps, so nothing in the pictures is
/// a frame the game could not reach.
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

    testWidgets('the frame laid on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 1);
      await layByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'frame-${phone.key}');
    });
  }

  testWidgets('the square laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'square');
  });

  testWidgets('the small square laid', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'smallsquare');
  });

  testWidgets('the small frame laid, one square shared', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'smallframe');
  });

  testWidgets('a frame mid-laying, a piece in hand', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapSlot(tester, 0);
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 3);
    await tapSquare(tester, 5, 0);
    await tapSlot(tester, 1);
    await press(tester, 'Turn');
    expect(state(tester).play.held, 1);
    await shoot(tester, 'midlay');
  });

  testWidgets('show me ghosting a laying', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await tapSlot(tester, 0);
    await tapSquare(tester, 0, 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the sliver shown, the frame never filled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await tapSlot(tester, 0);
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 1);
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await tapSquare(tester, 5, 2);
    await tapSlot(tester, 2);
    await press(tester, 'Turn');
    await press(tester, 'Flip');
    await tapSquare(tester, 0, 0);
    await tapSlot(tester, 3);
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await press(tester, 'Flip');
    await tapSquare(tester, 8, 0);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'sliver');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'frame-iphone-14.png',
      'square.png',
      'smallsquare.png',
      'smallframe.png',
      'midlay.png',
      'showme.png',
      'why.png',
      'sliver.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
