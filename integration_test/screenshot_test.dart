import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:latchword/best_score.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/round.dart';
import 'package:latchword/ui/app.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/game_screen.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/tracing.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A word game photographed at rest is a grid of letters, which says nothing
// about what playing it is like. So the picture that matters here is taken
// with the thumb still down, part way along a word, and the game already
// saying the letters so far are one.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// The board the pictures are taken on.
///
/// A round is a pure function of its seed, so this is the board a phone deals
/// on seed 7 rather than a board that only exists in a test. Its rows are
/// TMLBE / DYEPB / STEEE / INLUV / TEIHX.
const _seed = 7;

/// Traced before the picture, so the screen has a score on it and words under
/// it rather than being a round that has not started.
const _warmUp = <String>['beetle', 'entity'];

/// The word the picture is taken out of, and how much of it is traced when
/// the shutter goes.
///
/// Its first five squares spell STEEP, which is a word in its own right on a
/// different path across the same board. That is what makes this the moment
/// worth photographing: the trace is lit green and the line above the board
/// says the letters count, and there are still two squares to go. Both halves
/// of what the game does are in one frame.
const _word = 'steeple';
const _partWay = 5;

/// A record worth beating, so the screens show what the numbers look like for
/// a player who has been at it a while.
const _saved = <String, Object>{'best.points': 31, 'best.seed': 4096};

late final Lexicon _lexicon;
late final Board _board;

/// Sends a pointer event the way the device would rather than the way a test
/// does.
///
/// The two arrive at the game identically. The difference is that the live
/// binding paints a bright crosshair over wherever a test-sourced pointer
/// last was, and here that is the middle of the board in the one picture this
/// file exists to take.
Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

/// Puts a thumb on the glass at [at] and leaves it there.
Future<TestGesture> _thumbDown(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  return gesture;
}

/// Taps whatever [target] finds, in the middle of it.
///
/// By finder rather than by widget type: the screens here have more than one
/// button on them, and a tap that lands on the wrong one photographs the
/// wrong screen.
Future<void> _tap(WidgetTester tester, Finder target) async {
  expect(target, findsOneWidget);
  final gesture = await _thumbDown(tester, tester.getCenter(target));
  await gesture.up();
  await tester.pump();
}

/// How long the thumb rests on each square on its way across the board.
///
/// A drag with no time in it is still a legal trace, but the device sampler
/// takes a frame every couple of seconds and would never catch one. This is
/// about the speed a thumb crosses a board at.
const _perSquare = Duration(milliseconds: 70);

/// Drags across every square in [path] and leaves the thumb down.
Future<TestGesture> _traceTo(
  WidgetTester tester,
  List<Spot> path,
) async {
  final gesture =
      await _thumbDown(tester, middleOf(tester, _board, path.first));
  for (final spot in path.skip(1)) {
    await gesture.moveTo(middleOf(tester, _board, spot));
    await tester.pump(_perSquare);
  }
  return gesture;
}

/// Traces [word] and lifts, the way a player who has spotted it does.
Future<void> _find(WidgetTester tester, String word) async {
  final path = pathFor(_board, word);
  expect(path, isNotNull,
      reason: '$word is not on the board seed $_seed deals');
  final gesture = await _traceTo(tester, path!);
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Opens the game on the seeded board.
///
/// The app picks a fresh seed every round, which is right for a player and no
/// good for a photograph: a picture of a board nobody can name is a picture
/// nobody can check. Everything else is the app as it ships.
Future<void> _open(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(_saved));
  await tester.pumpWidget(MaterialApp(
    title: 'Latchword',
    debugShowCheckedModeBanner: false,
    theme: LatchwordApp.theme,
    home: GameScreen(
      lexicon: _lexicon,
      best: await BestScore.open(),
      seeds: () => _seed,
    ),
  ));
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere, it may be done only
  // once in a test, and the binding puts it back afterwards.
  await binding.convertFlutterSurfaceToImage();
}

/// Takes the picture, after a frame so that what is on screen is what the
/// last pump asked for.
Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Device pointers are dropped by a live test unless this is set. It goes
    // here rather than in a test body because the framework compares the flag
    // against what it was before each body and complains if a test moved it.
    binding.shouldPropagateDevicePointerEvents = true;

    _lexicon = Lexicon.standard();
    _board = Round.of(_seed, lexicon: _lexicon).board;
  });

  testWidgets('opens on a title anyone can read in one look', (tester) async {
    await _open(tester);

    expect(find.text('Latchword'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);

    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a word being traced, part way through', (
    tester,
  ) async {
    await _open(tester);
    await _tap(tester, find.text('Play'));
    expect(find.byType(BoardView), findsOneWidget,
        reason: 'Play did not start a round');

    for (final word in _warmUp) {
      await _find(tester, word);
    }

    final path = pathFor(_board, _word);
    expect(path, isNotNull, reason: '$_word is not on the board');
    final part = path!.take(_partWay).toList();
    expect(_board.wordFor(part), 'steep');
    expect(_board.judge(part), Refusal.none,
        reason: 'the moment only works if the letters so far are a word');

    final gesture = await _traceTo(tester, part);

    // A little past the middle of the last square, which is where a thumb
    // actually is and what the stub at the head of the trace is drawn to.
    final grid = GridGeometry.fit(
      tester.getRect(find.byType(BoardView)).size,
      _board.size,
    );
    await gesture.moveTo(
      middleOf(tester, _board, part.last) +
          Offset(grid.pitch * 0.24, grid.pitch * 0.24),
    );
    await tester.pump();

    expect(find.text('STEEP'), findsOneWidget,
        reason: 'the trace did not land on the squares it was aimed at');
    expect(find.text('+2'), findsOneWidget,
        reason: 'the game is not saying the letters so far count');
    await _shoot(tester, '02-tracing');

    // Then the rest of the word, which is what the picture is the middle of.
    for (final spot in path.skip(_partWay)) {
      await gesture.moveTo(middleOf(tester, _board, spot));
      await tester.pump(_perSquare);
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('+7'), findsOneWidget,
        reason: 'a seven letter word should have been worth seven');
    expect(find.text('3 words'), findsOneWidget);
    await _shoot(tester, '03-counted');

    // And the end of the round. The player ends it rather than the clock,
    // because two minutes of a build server waiting out a countdown buys
    // nothing the card does not already say.
    await _tap(tester, find.widgetWithText(TextButton, '×'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Round over'), findsOneWidget);
    expect(find.text('seed $_seed'), findsOneWidget,
        reason: 'the card should name the board these pictures were taken on');
    await _shoot(tester, '04-summary');
  });
}
