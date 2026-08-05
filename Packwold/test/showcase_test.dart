import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packwold/fit/play.dart';
import 'package:packwold/ui/app.dart';

import 'support/fit.dart';
import 'support/fonts.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every piece lying on a box in them was put there through the screen — out
/// of the tray, turned about, and tapped down — so nothing in the pictures is
/// a box the game could not reach.
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

  var opened = 0;

  Future<void> show(WidgetTester tester, Size size, {int? which}) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: PackwoldApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  /// Lays some of the pieces, the way a finger would.
  Future<void> packSome(WidgetTester tester, int howMany) async {
    final answer = state(tester).guide.answer;
    for (var piece = 0; piece < howMany && piece < answer.length; piece++) {
      await lay(tester, answer[piece]);
    }
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the puzzles on ${phone.key}', (tester) async {
      await show(tester, phone.value);
      await shoot(tester, 'puzzles-${phone.key}');
    });

    testWidgets('a box part packed on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 9);
      await packSome(tester, 5);
      await pick(tester, state(tester).play.letters.last);
      await press(tester, 'Turn');
      await shoot(tester, 'packing-${phone.key}');
    });

    testWidgets('being shown a piece on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 6);
      await packSome(tester, 2);
      await press(tester, 'Show me');
      expect(state(tester).pointing, hasLength(5));
      await shoot(tester, 'shown-${phone.key}');
    });
  }

  testWidgets('a piece that will not fit', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await packSome(tester, 2);

    // Somewhere the piece in hand would land across one already down.
    final piece = state(tester).play.letters.length - 1;
    await pick(tester, state(tester).play.letters[piece]);
    final box = state(tester).play.box;
    var found = false;
    for (var row = 0; row < box.deep && !found; row++) {
      for (var column = 0; column < box.wide && !found; column++) {
        if (state(tester).play.at(row, column) >= 0) continue;
        if (state(tester).play.whyNot(piece, row, column) !=
            Refusal.onAnother) {
          continue;
        }
        await touch(tester, row, column);
        found = true;
      }
    }
    expect(found, isTrue);
    expect(state(tester).saying, isNotNull);
    await shoot(tester, 'refused');
  });

  testWidgets('a box packed', (tester) async {
    await show(tester, phones['iphone-14']!, which: 4);
    await packIt(tester);
    expect(state(tester).play.isDone, isTrue);
    await shoot(tester, 'packed');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'puzzles-iphone-14.png',
      'packing-iphone-14.png',
      'shown-iphone-14.png',
      'refused.png',
      'packed.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
