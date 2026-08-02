import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/best_score.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/round.dart';
import 'package:latchword/ui/app.dart';
import 'package:latchword/ui/board_painter.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/chrome.dart';
import 'package:latchword/ui/game_screen.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:latchword/ui/hud.dart';
import 'package:latchword/ui/play_area.dart';
import 'package:latchword/ui/summary_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/tracing.dart';

/// The shipped list, so these are played on the boards the game really deals.
/// Building it takes long enough to be worth doing once.
final _lexicon = Lexicon.standard();

/// Short enough that a test can wait out the clock, long enough that nothing
/// here runs out of time by accident.
const _length = Duration(seconds: 30);

/// Two boards worth playing, in the order the game would deal them.
final _seeds = [1234, 4096];

Future<BestScore> _saved([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
  return BestScore(await SharedPreferences.getInstance());
}

/// A best score that counts the rounds handed to it.
///
/// A round is handed in exactly once when it ends, so this is how a test says
/// a round ended once and not twice.
class _Counted extends BestScore {
  _Counted(super.prefs);

  static Future<_Counted> open() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return _Counted(await SharedPreferences.getInstance());
  }

  int rounds = 0;

  @override
  Future<bool> record({required int points, required int seed}) {
    rounds++;
    return super.record(points: points, seed: seed);
  }
}

/// Tells the game the phone went away and came back, the way the system does.
Future<void> _lifecycle(WidgetTester tester, AppLifecycleState state) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.lifecycle.name,
    const StringCodec().encodeMessage(state.toString()),
    (_) {},
  );
}

/// Opens the game on a phone-shaped screen, on seeds of the test's choosing so
/// the same boards come up every time.
Future<void> _open(
  WidgetTester tester,
  BestScore best, {
  List<int>? seeds,
  Lexicon? lexicon,
  Size screen = const Size(1170, 2532),
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final deal = List<int>.from(seeds ?? _seeds);
  var next = 0;

  await tester.pumpWidget(MaterialApp(
    theme: LatchwordApp.theme,
    home: GameScreen(
      lexicon: lexicon ?? _lexicon,
      best: best,
      length: _length,
      seeds: () => deal[next++ % deal.length],
    ),
  ));
  await tester.pump();
}

/// Starts a round. One frame and never a settle: the clock is an animation
/// that runs for the whole round, so settling here would play the round out.
Future<void> _play(WidgetTester tester) async {
  await tester.tap(find.text('Play'));
  await tester.pump();
}

/// Taps a button on the end card, scrolling it into view first, because the
/// card is longer than a phone.
Future<void> _tapButton(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pump();
  await tester.tap(find.text(label));
  await tester.pump();
}

/// The board being played, which is the one the game is scoring.
Board _board(WidgetTester tester) =>
    tester.widget<PlayArea>(find.byType(PlayArea)).board;

List<String> _letters(Board board) => [
      for (var row = 0; row < board.size; row++)
        for (var col = 0; col < board.size; col++)
          board.letterAt(Spot(row, col)),
    ];

/// A word on the board with as few letters as possible, which is the quickest
/// one for a test to drag.
String _shortestWord(Board board) => board.everyWord.reduce(
      (best, word) => word.length < best.length ? word : best,
    );

/// A few words on the board, shortest first, so a test can build up a score
/// out of more than one word.
List<String> _someWords(Board board, int count) =>
    Round.ranked(board.everyWord).reversed.take(count).toList();

/// The score the game is showing, read off the readout the word count is
/// under rather than by looking for a number anywhere on the screen.
String _scoreShown(WidgetTester tester) => tester
    .widgetList<Readout>(find.descendant(
      of: find.byType(Hud),
      matching: find.byType(Readout),
    ))
    .firstWhere((readout) => readout.label.endsWith('word') ||
        readout.label.endsWith('words'))
    .value;

/// Long enough for the line above the board to have said its piece and gone,
/// so a test does not end with that timer still pending.
Future<void> _settleWord(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 2));

/// Waits out the clock, and then the card arriving.
Future<void> _runDown(WidgetTester tester) async {
  await tester.pump(_length + const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('the game opens on its title', (tester) async {
    await _open(tester, await _saved());

    expect(find.text('Latchword'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BoardPainter,
      ),
      findsOneWidget,
      reason: 'the mark on the title is a board with a word traced on it',
    );
    expect(find.byType(PlayArea), findsNothing);
  });

  testWidgets('the title says there is no best score until there is one',
      (tester) async {
    await _open(tester, await _saved());
    expect(find.text('no round finished yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await _open(tester, await _saved({'best.points': 21, 'best.seed': 512}));
    expect(find.text('best 21 on seed 512'), findsOneWidget);
  });

  testWidgets('Play deals a board and starts the clock', (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    expect(find.byType(PlayArea), findsOneWidget);
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('0 words'), findsOneWidget);
    expect(find.text('words you find land here'), findsOneWidget);
    expect(_board(tester).found, isEmpty);

    await tester.pump(const Duration(seconds: 10));
    expect(find.text('0:20'), findsOneWidget);
  });

  testWidgets('a word traced on the board is scored and listed',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);

    expect(_board(tester).found, [word]);
    expect(find.text('${Board.scoreOf(word)}'), findsWidgets);
    expect(find.text('1 word'), findsOneWidget);
    expect(find.text(word.toUpperCase()), findsWidgets,
        reason: 'the word joins the list under the board');
    expect(find.text('words you find land here'), findsNothing);

    await _settleWord(tester);
  });

  testWidgets('a word found twice is only worth it once', (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);
    await _settleWord(tester);
    await traceWord(tester, _board(tester), word);

    expect(_board(tester).found, [word]);
    expect(find.text('1 word'), findsOneWidget);

    await _settleWord(tester);
  });

  testWidgets('the clock running out ends the round', (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);
    await _runDown(tester);

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('${Board.scoreOf(word)}'), findsWidgets);
    expect(find.textContaining('of ${_board(tester).everyWord.length}'),
        findsOneWidget);
    expect(find.text('seed ${_seeds.first}'), findsOneWidget);
  });

  testWidgets('a player who is done before the clock is ends the round',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);
    await _settleWord(tester);

    // Not the back button, which iOS does not have.
    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('Round over'), findsOneWidget);
    expect(find.text('Time'), findsNothing);
    expect(find.text(word.toUpperCase()), findsWidgets,
        reason: 'a round ended early still counts what was found in it');
  });

  testWidgets('the end of the round shows what was on the board and missed',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    final round = Round.of(_seeds.first, lexicon: _lexicon);
    await _runDown(tester);

    expect(find.text('Found'), findsOneWidget);
    expect(find.text('nothing this time'), findsOneWidget);
    expect(find.textContaining('Missed'), findsOneWidget);
    // The longest word on the board is the one worth regretting, so it is at
    // the front of the list rather than lost in it.
    expect(find.text(round.missed.first.toUpperCase()), findsOneWidget);
    expect(find.textContaining('more'), findsOneWidget,
        reason: 'a board holds more words than a card can show');
  });

  testWidgets('the board stops taking words once the round is over',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);
    await _runDown(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);

    expect(_board(tester).found, isEmpty);
    expect(find.text('nothing this time'), findsOneWidget);
  });

  testWidgets('a new board is a new round on a fresh clock', (tester) async {
    await _open(tester, await _saved());
    await _play(tester);
    final first = _letters(_board(tester));
    await traceWord(tester, _board(tester), _shortestWord(_board(tester)));
    await _runDown(tester);

    await _tapButton(tester, 'New board');

    expect(find.byType(SummaryCard), findsNothing);
    expect(_letters(_board(tester)), isNot(first));
    expect(_board(tester).found, isEmpty);
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('0 words'), findsOneWidget);
  });

  testWidgets('the same board can be played again', (tester) async {
    await _open(tester, await _saved());
    await _play(tester);
    final first = _letters(_board(tester));
    await _runDown(tester);

    await _tapButton(tester, 'This board again');

    expect(_letters(_board(tester)), first,
        reason: 'a round is its seed, so the same seed is the same board');
    expect(_board(tester).found, isEmpty);
    expect(find.text('0:30'), findsOneWidget);
  });

  testWidgets('the title is a tap away from the end of a round',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);
    await _runDown(tester);

    await _tapButton(tester, 'Title');

    expect(find.text('Play'), findsOneWidget);
    expect(find.byType(PlayArea), findsNothing);
  });

  testWidgets('a round worth more than the record is kept', (tester) async {
    final best = await _saved();
    await _open(tester, best);
    await _play(tester);

    final word = _shortestWord(_board(tester));
    await traceWord(tester, _board(tester), word);
    await _runDown(tester);

    expect(find.text('New best'), findsOneWidget);
    expect(best.points, Board.scoreOf(word));
    expect(best.seed, _seeds.first);

    // What the next launch would open on.
    await _tapButton(tester, 'Title');
    expect(
      find.text('best ${Board.scoreOf(word)} on seed ${_seeds.first}'),
      findsOneWidget,
    );
  });

  testWidgets('a round that beat nothing says what there is to beat',
      (tester) async {
    await _open(tester, await _saved({'best.points': 500, 'best.seed': 7}));
    await _play(tester);
    await _runDown(tester);

    expect(find.text('New best'), findsNothing);
    expect(find.text('best 500 on seed 7'), findsOneWidget);
  });

  testWidgets('finding every word ends the round without waiting for the clock',
      (tester) async {
    // A board built against a list of two words holds two words, which is the
    // only way a test is clearing one inside a round.
    final small = Lexicon.of(const ['stare', 'star']);
    await _open(tester, await _saved(), lexicon: small);
    await _play(tester);

    for (final word in Round.ranked(_board(tester).everyWord)) {
      await traceWord(tester, _board(tester), word);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Board cleared'), findsOneWidget);
    expect(find.textContaining('Missed'), findsNothing);
    await _settleWord(tester);
  });

  testWidgets('the score on screen is the score the board kept',
      (tester) async {
    await _open(tester, await _saved());
    await _play(tester);

    var expected = 0;
    for (final word in _someWords(_board(tester), 3)) {
      await traceWord(tester, _board(tester), word);
      await _settleWord(tester);
      expected += Board.scoreOf(word);

      expect(_board(tester).score, expected);
      expect(_scoreShown(tester), '$expected');
    }
    expect(find.text('3 words'), findsOneWidget);

    await _runDown(tester);
    expect(
      tester
          .widgetList<Readout>(find.byType(Readout))
          .firstWhere((readout) => readout.label == 'points')
          .value,
      '$expected',
      reason: 'the card has to agree with the game that was just played',
    );
  });

  testWidgets('a round the clock ends is only ended once', (tester) async {
    final best = await _Counted.open();
    await _open(tester, best);
    await _play(tester);
    await traceWord(tester, _board(tester), _shortestWord(_board(tester)));
    await _settleWord(tester);
    await _runDown(tester);

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(best.rounds, 1);

    // The clock cannot come round again and end the same round twice.
    await tester.pump(_length);
    await tester.pump(_length);
    expect(best.rounds, 1);
    expect(find.byType(SummaryCard), findsOneWidget);
  });

  testWidgets('a round the player ends is not ended again by the clock',
      (tester) async {
    final best = await _Counted.open();
    await _open(tester, best);
    await _play(tester);
    await traceWord(tester, _board(tester), _shortestWord(_board(tester)));
    await _settleWord(tester);

    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(best.rounds, 1);

    // Past when the clock would have run out, if it were still running.
    await tester.pump(_length * 2);
    expect(best.rounds, 1);
    expect(find.text('Round over'), findsOneWidget);
    expect(find.text('Time'), findsNothing);
  });

  testWidgets('a board cleared early ends the round once and stops the clock',
      (tester) async {
    final best = await _Counted.open();
    await _open(tester, best, lexicon: Lexicon.of(const ['stare', 'star']));
    await _play(tester);

    for (final word in Round.ranked(_board(tester).everyWord)) {
      await traceWord(tester, _board(tester), word);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Board cleared'), findsOneWidget);
    expect(best.rounds, 1);

    await tester.pump(_length * 2);
    expect(best.rounds, 1);
    expect(find.text('Board cleared'), findsOneWidget);
    await _settleWord(tester);
  });

  testWidgets('a phone put down and picked up again does not gain time',
      (tester) async {
    // The clock is the time that passed, not the frames that were drawn: a
    // round left for twenty seconds has twenty seconds less in it, whether or
    // not the game was on screen to see them go.
    final best = await _Counted.open();
    await _open(tester, best);
    await _play(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('0:25'), findsOneWidget);

    await _lifecycle(tester, AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 20));
    await _lifecycle(tester, AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('0:05'), findsOneWidget);
    expect(best.rounds, 0, reason: 'the round is not over yet');

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(best.rounds, 1);
  });

  testWidgets('a word let go of after the round ended does not count',
      (tester) async {
    final best = await _Counted.open();
    await _open(tester, best);
    await _play(tester);

    // The thumb is still down when the clock stops.
    final board = _board(tester);
    final gesture =
        await thumbAcross(tester, board, pathFor(board, _shortestWord(board))!);
    await _runDown(tester);
    await gesture.up();
    await tester.pump();

    expect(_board(tester).found, isEmpty);
    expect(find.text('nothing this time'), findsOneWidget);
    expect(best.rounds, 1);
    await _settleWord(tester);
  });

  testWidgets('the way out of a round says what it does', (tester) async {
    // The one control on the game screen, and the glyph on it reads as a
    // multiplication sign to anything that reads screens out loud.
    final semantics = tester.ensureSemantics();
    await _open(tester, await _saved());
    await _play(tester);

    expect(
      tester.getSemantics(find.text('×')),
      isSemantics(
        label: 'end the round',
        isButton: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('a saved best score that is not a number opens on no record',
      (tester) async {
    // Whatever wrote these, it was not this game. Opening with no best score
    // is better than opening on a crash.
    await _open(tester, await _saved({'best.points': 'lots', 'best.seed': []}));

    expect(find.text('no round finished yet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _play(tester);
    await traceWord(tester, _board(tester), _shortestWord(_board(tester)));
    await _runDown(tester);
    expect(find.text('New best'), findsOneWidget);
  });

  testWidgets('a round fits a small phone at the largest text setting',
      (tester) async {
    // An iPhone SE, which is the smallest screen the game has to fit, at the
    // largest text setting a phone offers.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await _open(tester, await _saved(), screen: const Size(960, 1704));
    expect(tester.takeException(), isNull, reason: 'the title overflowed');
    expect(tester.getRect(find.text('Play')).bottom, lessThanOrEqualTo(568),
        reason: 'the one button on the title has to be on the screen');

    await _play(tester);
    await traceWord(tester, _board(tester), _shortestWord(_board(tester)));
    expect(tester.takeException(), isNull, reason: 'the round overflowed');

    final grid = GridGeometry.fit(
      tester.getRect(find.byType(BoardView)).size,
      _board(tester).size,
    );
    expect(grid.side, greaterThanOrEqualTo(44),
        reason: 'a square has to stay big enough for a thumb');

    await _runDown(tester);
    expect(tester.takeException(), isNull, reason: 'the end card overflowed');
  });
}
