import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moor.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every pane in them was tapped, so nothing in the pictures is a
/// sash the game could not reach.
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
    testWidgets('the moor on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'moor-${phone.key}');
    });

    testWidgets('the nine landed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await setAll(tester, const [
        (0, 0), (0, 1), (0, 2),
        (1, 0), (1, 3),
        (2, 1), (2, 3),
        (3, 2), (3, 3),
      ]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'nine-${phone.key}');
    });
  }

  testWidgets('a window framed and called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, const [(0, 0), (2, 0), (0, 2), (2, 2)]);
    expect(state(tester).play.windows, 1);
    await shoot(tester, 'window');
  });

  testWidgets('the casement glazed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'casement');
  });

  testWidgets('show me ringing a light', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the tenth pane admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    final lights = state(tester).play.rules.lights;
    for (final (x, y) in lights.take(10)) {
      await tapLight(tester, x, y);
    }
    for (var touch = 10; touch < 16; touch++) {
      await tapLight(tester, 0, 0);
    }
    await shoot(tester, 'tenthpane');
  });

  testWidgets('the eight mid-glaze', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await setAll(tester, const [(0, 0), (0, 1), (1, 2), (1, 3), (2, 0)]);
    expect(state(tester).play.windows, 0);
    expect(state(tester).play.isDone, isFalse);
    await shoot(tester, 'midglaze');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'moor-iphone-14.png',
      'nine-iphone-14.png',
      'window.png',
      'casement.png',
      'showme.png',
      'why.png',
      'tenthpane.png',
      'midglaze.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
