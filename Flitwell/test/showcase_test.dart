import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/flitland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real phone
/// dimensions, drawn by the engine the app uses.
///
/// Every tenant in them was moved by a tap on a tenant, so nothing in
/// the pictures is a lane the game could not reach.
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
    testWidgets('the lane on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'lane-${phone.key}');
    });

    testWidgets('the firm lane on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await landByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'firm-${phone.key}');
    });
  }

  testWidgets('the shared street as it opens', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    expect(state(tester).play.swaps, 0);
    await shoot(tester, 'opening');
  });

  testWidgets('the willing lane landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'willing');
  });

  testWidgets('the unbeaten lane landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'unbeaten');
  });

  testWidgets('a tenant picked up, part way through', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await swap(tester, 0, 1);
    await tapTenant(tester, 2);
    expect(state(tester).play.held, 2);
    await shoot(tester, 'midway');
  });

  testWidgets('show me lighting two tenants', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the better lane given up', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (final pair in [(0, 1), (2, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothingbeats');
  });

  testWidgets('the better lane given up, on the small phone', (tester) async {
    await show(tester, phones['iphone-se']!, which: 4);
    for (final pair in [(0, 1), (2, 3), (0, 2), (1, 3), (0, 3), (1, 2)]) {
      await swap(tester, pair.$1, pair.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'nothingbeats-small');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'lane-iphone-14.png',
      'firm-iphone-14.png',
      'opening.png',
      'willing.png',
      'unbeaten.png',
      'midway.png',
      'showme.png',
      'why.png',
      'nothingbeats.png',
      'nothingbeats-small.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(14));
  });
}
