import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyloom/game/book.dart';
import 'package:tallyloom/game/line.dart';
import 'package:tallyloom/game/maker.dart';
import 'package:tallyloom/game/solver.dart';
import 'package:tallyloom/ui/app.dart';

import 'support/playing.dart';

/// Renders the game at real phone sizes and writes the pictures out.
///
/// Nothing here can fail on a pixel. It exists to produce pictures of the game
/// for somebody to look at, and it is the real widget tree at real phone
/// dimensions drawn by the engine the app uses, which is as close to a phone
/// as a machine with no phone attached can get. Pictures from an actual
/// emulator and simulator come from CI.
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
    // picture. The clues are numbers, so this is not a detail here: without
    // the real face every clue in every shot is a black rectangle.
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

  Future<void> capture(WidgetTester tester, String name) async {
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

  Future<void> show(
    WidgetTester tester,
    Size size, {
    int? at,
    Map<String, Object> record = const {},
  }) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: screen,
        child: MediaQuery(
          data: MediaQueryData(size: size, devicePixelRatio: ratio),
          child: TallyloomApp(
            progress: await saved(record),
            opensAt: at,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Plays a puzzle the way a player would up to a point: everything line
  /// logic settles in [passes] sweeps, put down with the thumb.
  ///
  /// This is why the half finished shots look like a real position. They are
  /// one: every square in them is a square that follows from the clues, and
  /// nothing has been filled in that a player could not have reasoned out by
  /// then.
  Future<void> workItOut(
    WidgetTester tester,
    Puzzle puzzle, {
    required int passes,
    bool crosses = true,
  }) async {
    final sofar = solve(puzzle.clues, limit: passes).grid;

    for (var row = 0; row < puzzle.height; row++) {
      for (var col = 0; col < puzzle.width; col++) {
        if (sofar.at(row, col) != Square.filled) continue;
        await tapSquare(tester, row, col);
      }
    }
    if (!crosses) return;

    await tester.tap(find.text('Cross'));
    await tester.pump();
    for (var row = 0; row < puzzle.height; row++) {
      for (var col = 0; col < puzzle.width; col++) {
        if (sofar.at(row, col) != Square.blank) continue;
        await tapSquare(tester, row, col);
      }
    }
    await tester.tap(find.text('Fill'));
    await tester.pump();
  }

  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': Size(390, 844),
    'pixel-7': Size(412, 915),
  };

  for (final phone in phones.entries) {
    testWidgets('the title on ${phone.key}', (tester) async {
      await show(tester, phone.value, record: const {'took.1': 41, 'took.2': 96});
      await capture(tester, 'title-${phone.key}');
    });

    testWidgets('a puzzle under way on ${phone.key}', (tester) async {
      await show(tester, phone.value, at: 31);
      await workItOut(tester, Book.at(31), passes: 1);
      await tester.pump(const Duration(seconds: 47));
      await capture(tester, 'working-${phone.key}');
    });
  }

  testWidgets('a small one, most of the way through', (tester) async {
    await show(tester, phones['iphone-14']!, at: 8);
    await workItOut(tester, Book.at(8), passes: 2);
    await tester.pump(const Duration(seconds: 23));
    await capture(tester, 'small');
  });

  testWidgets('crossing off where the picture is not', (tester) async {
    await show(tester, phones['iphone-14']!, at: 31);
    await workItOut(tester, Book.at(31), passes: 2);
    await tester.tap(find.text('Cross'));
    await tester.pump(const Duration(seconds: 88));
    await capture(tester, 'crossing');
  });

  testWidgets('the puzzle coming out', (tester) async {
    final puzzle = Book.at(31);
    await show(tester, phones['iphone-14']!, at: 31, record: {'took.31': 400});
    await tester.pump(const Duration(seconds: 205));
    await workItOut(tester, puzzle, passes: 99, crosses: false);
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'out');
  });

  testWidgets('put down part way through', (tester) async {
    await show(tester, phones['iphone-14']!, at: 31);
    await workItOut(tester, Book.at(31), passes: 1);
    await tester.pump(const Duration(seconds: 62));
    await goAway(tester);
    await comeBack(tester);
    await capture(tester, 'paused');
  });
}
