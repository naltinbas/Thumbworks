import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/bondland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every coin in them was put in its purse by a tap, so no division
/// pictured is one the game could not reach.
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

    testWidgets('the large estate on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await setPurses(tester, [6, 12, 18]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'large-${phone.key}');
    });
  }

  testWidgets('the small estate', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setPurses(tester, [4, 4, 4]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'small');
  });

  testWidgets('the middling estate', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await setPurses(tester, [6, 9, 9]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'middling');
  });

  testWidgets('the fuller estate', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await divideByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fuller');
  });

  testWidgets('the long bond admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await setPurses(tester, [0, 0, 12]);
    await setPurses(tester, [0, 3, 9]);
    await setPurses(tester, [3, 3, 6]);
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'longbond');
  });

  testWidgets('a scale out of true, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 1);
    await setPurses(tester, [9, 6, 6]);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'outoftrue');
  });

  testWidgets('show me naming the purse', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await setPurses(tester, [6, 9, 9]);
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
      'large-iphone-14.png',
      'small.png',
      'middling.png',
      'fuller.png',
      'longbond.png',
      'outoftrue.png',
      'showme.png',
      'why.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
