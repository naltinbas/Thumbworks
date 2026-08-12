import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/combeland.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every wire in them was tapped, so nothing in the pictures is a
/// combe the game could not reach.
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
    testWidgets('the combeland on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'combeland-${phone.key}');
    });

    testWidgets('the star wired on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await wireAll(tester, const [(0, 1), (0, 2), (0, 3), (0, 4)]);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'star-${phone.key}');
    });
  }

  testWidgets('the long lane wired', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await wireAll(tester, const [(0, 1), (1, 2), (2, 3), (3, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'longlane');
  });

  testWidgets('a loop called out', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await wireAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    await shoot(tester, 'loop');
  });

  testWidgets('a star where a lane was asked', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await wireAll(tester, const [(0, 1), (0, 2), (0, 3), (0, 4)]);
    await shoot(tester, 'wrongshape');
  });

  testWidgets('show me pointing a wire', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the ring round admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var round = 0; round < 6; round++) {
      await wireLine(tester, (0, 1));
      await wireLine(tester, (0, 1));
    }
    await shoot(tester, 'ringround');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'combeland-iphone-14.png',
      'star-iphone-14.png',
      'longlane.png',
      'loop.png',
      'wrongshape.png',
      'showme.png',
      'why.png',
      'ringround.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
