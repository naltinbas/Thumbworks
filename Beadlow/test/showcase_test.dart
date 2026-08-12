import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/bead.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every shelf in them was strung bead by bead, so nothing in the
/// pictures is a stall the game could not reach.
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
    testWidgets('the rings on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'rings-${phone.key}');
    });

    testWidgets('the fourteen mid-stringing on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      for (var strung = 0; strung < 6; strung++) {
        final missing = state(tester).play.missing!;
        for (var at = 0; at < missing.length; at++) {
          await dyeTo(tester, at, missing[at]);
        }
        await press(tester, 'String it');
      }
      await shoot(tester, 'stringing-${phone.key}');
    });

    testWidgets('a shelf filled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 2);
      await shelveIt(tester);
      await shoot(tester, 'shelved-${phone.key}');
    });
  }

  testWidgets('a repeat named', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await dyeTo(tester, 0, 1);
    await press(tester, 'String it');
    await dyeTo(tester, 0, 0);
    await dyeTo(tester, 1, 1);
    await press(tester, 'String it');
    expect(state(tester).named, 0);
    await shoot(tester, 'repeat');
  });

  testWidgets('the counting spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the seventh jammed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    var guard = 0;
    while (state(tester).play.strung.length < 6) {
      if (guard++ > 10) fail('the shelf never filled');
      final missing = state(tester).play.missing!;
      for (var at = 0; at < 4; at++) {
        await dyeTo(tester, at, missing[at]);
      }
      await press(tester, 'String it');
    }
    await press(tester, 'String it');
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'seventh');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'rings-iphone-14.png',
      'stringing-iphone-14.png',
      'shelved-iphone-14.png',
      'repeat.png',
      'why.png',
      'seventh.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
