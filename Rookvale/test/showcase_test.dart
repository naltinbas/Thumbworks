import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rookvale/board/puzzles.dart';
import 'package:rookvale/board/solve.dart';
import 'package:rookvale/ui/app.dart';

import 'support/board.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at: the real widget tree at real phone dimensions,
/// drawn by the engine the app uses.
///
/// Every capture in them was made by tapping the piece and then what it took,
/// so nothing in the pictures is a position the game would not allow.
///
/// Run it with: make shots
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;
  const screen = Key('screen');

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test renders text with a placeholder face that draws every glyph as a
    // filled box, which is fine for measuring a layout and useless in a
    // picture.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    for (final family in const ['Roboto', 'MaterialIcons']) {
      final loader = FontLoader(family);
      for (final file in fonts.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (!name.startsWith(family)) continue;
        if (!name.endsWith('.ttf') && !name.endsWith('.otf')) continue;
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  });

  Future<void> capturePng(WidgetTester tester, String name) async {
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
        child: RookvaleApp(key: ValueKey(opened++), opensAt: which),
      ),
    );
    await tester.pump();
  }

  /// Makes a few of the captures on the way through.
  Future<void> playOn(WidgetTester tester, int takes) async {
    for (var i = 0; i < takes; i++) {
      if (state(tester).play.isOver) return;
      final next = state(tester).play.nextTake;
      if (next == null) return;
      await capture(tester, next.from, next.to);
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
      await capturePng(tester, 'puzzles-${phone.key}');
    });

    testWidgets('a piece picked on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 9);
      await playOn(tester, 2);
      // Picked but not yet taken, so the squares it can take on are ringed.
      final next = state(tester).play.nextTake!;
      await tapSquare(tester, next.from);
      await capturePng(tester, 'picked-${phone.key}');
    });

    testWidgets('a board part way through on ${phone.key}', (tester) async {
      await show(tester, phone.value, which: 7);
      await playOn(tester, 3);
      await capturePng(tester, 'playing-${phone.key}');
    });
  }

  testWidgets('a capture that ruins it', (tester) async {
    await show(tester, phones['iphone-14']!, which: 0);
    final right = waysThrough(Puzzles.at(0).board).first.first;
    final wrong = Puzzles.at(0).board.moves.firstWhere((m) => m != right);
    await capture(tester, wrong.from, wrong.to);
    expect(state(tester).saying, contains('no way through'));
    await capturePng(tester, 'ruined');
  });

  testWidgets('one piece left', (tester) async {
    await show(tester, phones['iphone-14']!, which: 5);
    await playOn(tester, 12);
    expect(state(tester).play.isDone, isTrue);
    await capturePng(tester, 'one-left');
  });

  test('the shots are all there', () {
    final made = Directory(shots)
        .listSync()
        .map((file) => file.uri.pathSegments.last)
        .toList();
    for (final wanted in const [
      'puzzles-iphone-14.png',
      'picked-iphone-14.png',
      'playing-iphone-14.png',
      'ruined.png',
      'one-left.png',
    ]) {
      expect(made, contains(wanted));
    }
    expect(made.length, greaterThanOrEqualTo(11));
  });
}
