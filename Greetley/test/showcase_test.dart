import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fete.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every shake in them was tapped, so nothing in the pictures is a
/// lawn the game could not reach.
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

  Future<void> shakeByPointer(WidgetTester tester) async {
    var guard = 0;
    while (!state(tester).play.isDone && guard++ < 12) {
      await press(tester, 'Show me');
      final ((a, b), _) = state(tester).pointing!;
      await shake(tester, (a, b));
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the fete on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'fete-${phone.key}');
    });

    testWidgets('the four odd greeted on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 2);
      await shakeByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'fourodd-${phone.key}');
    });
  }

  testWidgets('the two odd greeted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await shake(tester, (0, 2));
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'twoodd');
  });

  testWidgets('the quiet lawn rounded', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await shakeAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'quietlawn');
  });

  testWidgets('a hand offered', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await shake(tester, (0, 1));
    await tapGuest(tester, 2);
    await shoot(tester, 'offered');
  });

  testWidgets('show me pointing a shake', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the odd guest admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 6; round++) {
      await shake(tester, (0, 1));
      await shake(tester, (0, 1));
    }
    await shoot(tester, 'oddguest');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'fete-iphone-14.png',
      'fourodd-iphone-14.png',
      'twoodd.png',
      'quietlawn.png',
      'offered.png',
      'showme.png',
      'why.png',
      'oddguest.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
