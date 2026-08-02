import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/best_score.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/round.dart';
import 'package:latchword/ui/app.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/game_screen.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/tracing.dart';

/// Renders the game at real phone sizes and writes the frames out as PNGs.
///
/// Nothing here can fail on a pixel and there are no golden files to keep up
/// to date: it exists to produce pictures of the game for someone to look at.
/// It is the real widget tree at real dimensions, drawn by the same engine the
/// app uses, and it takes a second instead of an emulator.
///
/// It runs with the rest of the suite, so the pictures in build/showcase are
/// always of the code as it stands. On its own:
/// flutter test test/showcase_test.dart
void main() {
  const shots = 'build/showcase';
  const ratio = 3.0;

  // The same round every time, so a change to the drawing shows up in these
  // pictures and a change to the maker does not. A round is its seed, so the
  // board here is the board this seed deals on a phone.
  const seed = 7;
  final lexicon = Lexicon.standard();
  final board = Round.of(seed, lexicon: lexicon).board;

  /// A record worth beating, so the screens show what the numbers look like
  /// once a player has been at it for a while.
  const record = <String, Object>{'best.points': 31, 'best.seed': 4096};

  /// The word the picture of a trace is taken out of, and how far along it
  /// the thumb has got when the shutter goes.
  const traced = 'steeple';
  const partWay = 5;

  setUpAll(() async {
    Directory(shots).createSync(recursive: true);

    // A test draws every glyph as a filled box until a real face is loaded,
    // which is no use at all in a picture of a game made of letters.
    final fonts = Directory(
      '${Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter'}'
      '/bin/cache/artifacts/material_fonts',
    );
    final loader = FontLoader('Roboto');
    for (final file in fonts.listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.startsWith('Roboto') || !name.endsWith('.ttf')) continue;
      loader.addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  });

  const screen = Key('screen');

  Future<void> open(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size * ratio
      ..devicePixelRatio = ratio;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(
      Map<String, Object>.from(record),
    );
    final best = BestScore(await SharedPreferences.getInstance());

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LatchwordApp.theme,
      home: RepaintBoundary(
        key: screen,
        child: GameScreen(lexicon: lexicon, best: best, seeds: () => seed),
      ),
    ));
    await tester.pump();
  }

  /// Long enough after a word for the answer above the board to have been and
  /// gone. It is time off the round's clock, like any other pause.
  const pause = Duration(seconds: 2);

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

  /// Starts the round. Never a settle: the clock runs for the whole round, so
  /// settling here would play it out.
  Future<void> play(WidgetTester tester) async {
    await tester.tap(find.text('Play'));
    await tester.pump();
  }

  /// Finds a few words, the way a player a minute into a round has. It spends
  /// [pause] on each, which is the round's own clock running down.
  Future<void> findSome(WidgetTester tester, int count) async {
    for (final word in _worthFinding(board).take(count)) {
      await traceWord(tester, board, word);
      await tester.pump(pause);
    }
  }

  const phone = Size(390, 844);
  const phones = <String, Size>{
    'iphone-se': Size(320, 568),
    'iphone-14': phone,
    'pixel-7': Size(412, 915),
  };

  for (final entry in phones.entries) {
    testWidgets('the title on ${entry.key}', (tester) async {
      await open(tester, entry.value);
      await capture(tester, 'title-${entry.key}');
    });

    testWidgets('a round under way on ${entry.key}', (tester) async {
      await open(tester, entry.value);
      await play(tester);
      await tester.pump(const Duration(seconds: 34));
      await findSome(tester, 3);
      await capture(tester, 'round-${entry.key}');
    });
  }

  testWidgets('a word being traced, part way through', (tester) async {
    await open(tester, phone);
    await play(tester);
    await findSome(tester, 2);

    // Stopped where the letters so far are already a word on their own, so
    // the trace is green and the line above the board says what it is worth
    // with two squares still to go. It is the moment CI photographs on a
    // phone, so if this stops being that moment the drive there has stopped
    // being it too.
    final path = pathFor(board, traced)!.take(partWay).toList();
    expect(board.wordFor(path), 'steep');
    expect(board.judge(path), Refusal.none);

    final gesture = await thumbAcross(tester, board, path);

    // A little past the middle of the last square, which is where a thumb
    // actually is and what the stub at the head of the trace is drawn to.
    final grid = GridGeometry.fit(
      tester.getRect(find.byType(BoardView)).size,
      board.size,
    );
    final past = Offset(grid.pitch * 0.24, grid.pitch * 0.24);
    await gesture.moveTo(middleOf(tester, board, path.last) + past);
    await tester.pump();

    expect(find.text('STEEP'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    await capture(tester, 'tracing');

    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the moment a word counts', (tester) async {
    await open(tester, phone);
    await play(tester);
    final gesture = await thumbAcross(
      tester,
      board,
      pathFor(board, _worthFinding(board).first)!,
    );
    await gesture.up();

    // Part way through the word being taken, while it is still swelling.
    await tester.pump(const Duration(milliseconds: 140));
    await capture(tester, 'counted');

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a trace that spells nothing', (tester) async {
    await open(tester, phone);
    await play(tester);
    final gesture = await thumbAcross(
      tester,
      board,
      pathSpellingNothing(board)!,
    );
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 140));
    await capture(tester, 'refused');

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the last seconds of a round', (tester) async {
    const found = 4;
    await open(tester, phone);
    await play(tester);
    await findSome(tester, found);

    // Eight seconds left, which is the clock in the colour it spends the end
    // of every round in.
    await tester.pump(
      Round.standardLength - pause * found - const Duration(seconds: 8),
    );
    await capture(tester, 'running-out');
  });

  testWidgets('the end of a round', (tester) async {
    await open(tester, phone);
    await play(tester);
    await findSome(tester, 5);
    await tester.pump(Round.standardLength);
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'summary');
  });

  testWidgets('the round waiting to be picked back up', (tester) async {
    await open(tester, phone);
    await play(tester);
    await findSome(tester, 3);

    // Away and back, one state at a time, the way a phone takes an app there.
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    await capture(tester, 'paused');
  });
}

/// The words on a board a picture wants found: the best ones, shortest first
/// among equals, so the list under the board reads like a good round rather
/// than a lucky one. Only words a thumb can actually be dragged across get in,
/// which is every word on the board bar the odd one the tracer cannot route.
List<String> _worthFinding(Board board) => Round.ranked(board.everyWord)
    .where((word) => pathFor(board, word) != null)
    .toList();
