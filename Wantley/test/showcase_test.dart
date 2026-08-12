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
/// Every path in them was tapped, so nothing in the pictures is a
/// treading the game could not reach.
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
    testWidgets('the green on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'green-${phone.key}');
    });

    testWidgets('the one way landed on ${phone.key}',
        (tester) async {
      await show(tester, phone.value, which: 3);
      await landByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'oneway-${phone.key}');
    });
  }

  testWidgets('the four ones landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await tapPath(tester, 0);
    await tapPath(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'fourones');
  });

  testWidgets('the round wish landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'roundwish');
  });

  testWidgets('the seven ways landed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'sevenways');
  });

  testWidgets('a green mid-tread, one farm over', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await tapPath(tester, 0);
    await tapPath(tester, 1);
    await tapPath(tester, 2);
    await tapPath(tester, 3);
    expect(state(tester).play.counts[0], 4);
    await shoot(tester, 'midtread');
  });

  testWidgets('show me ringing a path', (tester) async {
    await show(tester, phones['iphone-14']!, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the three threes admitted', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    // Tread the three farms to each other and all to the last:
    // the finger proof on the table, the last farm three over.
    for (var pair = 0; pair < 6; pair++) {
      await tapPath(tester, pair);
      expect(state(tester).play.trodden[pair], isTrue,
          reason: 'pair $pair');
    }
    for (var lift = 0; lift < 3; lift++) {
      await tapPath(tester, 0);
      await tapPath(tester, 0);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(state(tester).play.paths, 6);
    expect(state(tester).play.counts, [3, 3, 3, 3]);
    await shoot(tester, 'threethrees');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'green-iphone-14.png',
      'oneway-iphone-14.png',
      'fourones.png',
      'roundwish.png',
      'sevenways.png',
      'midtread.png',
      'showme.png',
      'why.png',
      'threethrees.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(12));
  });
}
