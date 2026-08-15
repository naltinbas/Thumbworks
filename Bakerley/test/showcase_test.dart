import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/trayland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every four in them was laid by a tap, so nothing in the pictures is
/// a tray the game could not reach.
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

    testWidgets('the pinwheel on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 0);
      await fillByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'pinwheel-${phone.key}');
    });
  }

  testWidgets('the four elbows', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'elbows');
  });

  testWidgets('the mixed tray', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'mixed');
  });

  testWidgets('the long tray', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'long');
  });

  testWidgets('mid-filling, a skew held', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await lay(tester, 2, 0, 0, 0);
    await lay(tester, 2, 3, 1, 0);
    await takeKind(tester, 3);
    await press(tester, 'Turn');
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midfilling');
  });

  testWidgets('show me ringing the cells', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await takeKind(tester, 0);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the five admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await lay(tester, 2, 3, 0, 0);
    await lay(tester, 0, 1, 0, 2);
    await lay(tester, 1, 0, 3, 0);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'five');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'pinwheel-iphone-14.png',
      'elbows.png',
      'mixed.png',
      'long.png',
      'midfilling.png',
      'showme.png',
      'why.png',
      'five.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
