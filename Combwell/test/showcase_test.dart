import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of
/// the game for somebody to look at: the real widget tree at real
/// phone dimensions, drawn by the engine the app uses.
///
/// Every number in them was put by taps, so nothing in the pictures is
/// a comb the game could not reach.
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

    testWidgets('the whole comb filled on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 3);
      await fillByPointer(tester);
      expect(state(tester).play.isDone, isTrue);
      await shoot(tester, 'wholecomb-${phone.key}');
    });
  }

  testWidgets('the last four filled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    await fill(tester, 8, 2);
    await fill(tester, 9, 5);
    await fill(tester, 10, 6);
    await fill(tester, 13, 4);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lastfour');
  });

  testWidgets('the last seven filled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lastseven');
  });

  testWidgets('the last ten filled', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'lastten');
  });

  testWidgets('a comb mid-filling, a line off', (tester) async {
    await show(tester, phones['iphone-14']!, which: 2);
    await fill(tester, 1, 2);
    await fill(tester, 4, 7);
    await tapCell(tester, 6);
    expect(state(tester).play.wrongLines, isNotEmpty);
    await shoot(tester, 'midfill');
  });

  testWidgets('show me ringing a cell', (tester) async {
    await show(tester, phones['iphone-14']!, which: 1);
    await press(tester, 'Show me');
    await shoot(tester, 'showme');
  });

  testWidgets('the why spoken', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await press(tester, 'Why');
    await shoot(tester, 'why');
  });

  testWidgets('the thirty-seven admitted, the comb full', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    for (var c = 0; c < 19; c++) {
      await fill(tester, c, c + 1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    await shoot(tester, 'thirtyseven');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'sham-iphone-14.png',
      'wholecomb-iphone-14.png',
      'lastfour.png',
      'lastseven.png',
      'lastten.png',
      'midfill.png',
      'showme.png',
      'why.png',
      'thirtyseven.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(13));
  });
}
