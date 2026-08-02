import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:latchword/ui/palette.dart';
import 'package:latchword/ui/play_area.dart';

/// A board small enough to say what is on it, and only the words these tests
/// are about, so nothing here depends on the shipped list.
///
///   s t a r
///   z a z e
///   z z z z
///   z z z z
///
/// star and rats run along the top row either way, stare carries on into the
/// e below the r, and staz is a trace that spells nothing.
final _lexicon = Lexicon.of(['star', 'stare', 'rats', 'east']);

Board _board() => Board(
      size: 4,
      letters: 'starzazezzzzzzzz'.split(''),
      lexicon: _lexicon,
    );

const _star = [Spot(0, 0), Spot(0, 1), Spot(0, 2), Spot(0, 3)];
const _stare = [..._star, Spot(1, 3)];
const _staz = [Spot(0, 0), Spot(0, 1), Spot(0, 2), Spot(1, 2)];

/// Where on the screen the middle of a square is, worked out with the same
/// geometry the view lays itself out with.
Offset _middleOf(WidgetTester tester, Spot spot) {
  final box = tester.getRect(find.byType(BoardView));
  return box.topLeft + GridGeometry.fit(box.size, 4).centreOf(spot);
}

/// Off the top right corner, where a thumb carrying on past the last square
/// of the top row ends up.
Offset _pastTheCorner(WidgetTester tester) {
  final box = tester.getRect(find.byType(BoardView));
  return box.topLeft +
      GridGeometry.fit(box.size, 4).grid.topRight +
      const Offset(30, -30);
}

/// Any shape put down in this colour whatever call drew it, and whatever it
/// was faded to. Colours are compared as packed bytes because a Paint keeps
/// them as floats.
bool Function(Symbol, List<dynamic>) _anythingDrawnIn(Color colour) =>
    (method, arguments) {
      final paint = arguments.isEmpty ? null : arguments.last;
      if (paint is! Paint) return false;
      return paint.color.toARGB32() & 0xFFFFFF ==
          colour.toARGB32() & 0xFFFFFF;
    };

/// How long the board takes to put a lifted trace away.
const _settle = Duration(milliseconds: 400);

void main() {
  late Board latest;

  Future<void> open(WidgetTester tester) async {
    final board = _board();
    latest = board;
    await tester.pumpWidget(MaterialApp(
      home: PlayArea(board: board, onBoard: (played) => latest = played),
    ));
  }

  /// Puts a thumb on the first square and drags it through the rest, without
  /// lifting it.
  Future<TestGesture> thumbAcross(
    WidgetTester tester,
    List<Spot> path,
  ) async {
    final gesture = await tester.startGesture(_middleOf(tester, path.first));
    await tester.pump();
    for (final spot in path.skip(1)) {
      await gesture.moveTo(_middleOf(tester, spot));
      await tester.pump();
    }
    return gesture;
  }

  Future<void> traceWord(WidgetTester tester, List<Spot> path) async {
    final gesture = await thumbAcross(tester, path);
    await gesture.up();
    await tester.pump();
  }

  /// Waits out the moment the answer stays up for, which every test that let
  /// go of a trace has to do before it ends.
  Future<void> quiet(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 2));

  /// Nothing of a trace is left drawn on the board. Every colour a trace can
  /// be, because a stuck trace is stuck in whichever one it ended in.
  void expectNothingTraced(WidgetTester tester, String when) {
    for (final colour in [Palette.trace, Palette.word, Palette.stale]) {
      expect(
        find.byType(BoardView),
        isNot(paints..something(_anythingDrawnIn(colour))),
        reason: 'a trace was still on the board $when',
      );
    }
  }

  /// A point between four squares, where a thumb takes nothing.
  Offset betweenSquares(WidgetTester tester, Spot spot) {
    final box = tester.getRect(find.byType(BoardView));
    final pitch = GridGeometry.fit(box.size, 4).pitch;
    return _middleOf(tester, spot) + Offset(pitch / 2, pitch / 2);
  }

  testWidgets('spells out the word a thumb drags across', (tester) async {
    await open(tester);

    await traceWord(tester, _stare);

    expect(find.text('STARE'), findsOneWidget);
    expect(latest.found, contains('stare'));
    expect(latest.score, Board.scoreOf('stare'));
    await quiet(tester);
  });

  testWidgets('shows the letters taken so far while the thumb is still down',
      (tester) async {
    await open(tester);

    final gesture = await thumbAcross(tester, [_star[0], _star[1], _star[2]]);

    expect(find.text('STA'), findsOneWidget);
    expect(latest.found, isEmpty, reason: 'nothing is taken until it lifts');

    await gesture.up();
    await tester.pump();
    await quiet(tester);
  });

  testWidgets('says a word counts before the thumb lifts', (tester) async {
    await open(tester);

    final gesture = await thumbAcross(tester, _stare);

    expect(find.text('STARE'), findsOneWidget);
    expect(find.text('+${Board.scoreOf('stare')}'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    await quiet(tester);
  });

  testWidgets('draws the trace in the colour of a real word as it becomes one',
      (tester) async {
    await open(tester);

    final gesture = await thumbAcross(tester, [_star[0], _star[1], _star[2]]);
    expect(
      find.byType(BoardView),
      isNot(paints..something(_anythingDrawnIn(Palette.word))),
      reason: 'sta is not a word yet',
    );

    await gesture.moveTo(_middleOf(tester, _star[3]));
    await tester.pump();
    expect(
      find.byType(BoardView),
      paints..something(_anythingDrawnIn(Palette.word)),
      reason: 'star is',
    );

    await gesture.up();
    await tester.pump();
    await quiet(tester);
  });

  testWidgets('does not pick up a square a diagonal only cuts across',
      (tester) async {
    await open(tester);

    // Straight from the s to the a below and right of it. The t and the z it
    // passes between are not part of the word.
    final gesture =
        await thumbAcross(tester, const [Spot(0, 0), Spot(1, 1)]);

    expect(find.text('SA'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    await quiet(tester);
  });

  testWidgets('gives back a square when the thumb returns to the one before',
      (tester) async {
    await open(tester);

    await traceWord(tester, [..._star, const Spot(0, 2)]);

    expect(find.text('STA'), findsOneWidget);
    expect(find.text('too short'), findsOneWidget);
    expect(latest.found, isEmpty);
    await quiet(tester);
  });

  testWidgets('keeps the trace when the thumb lifts off the grid',
      (tester) async {
    await open(tester);

    final gesture = await thumbAcross(tester, _star);
    await gesture.moveTo(_pastTheCorner(tester));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('STAR'), findsOneWidget);
    expect(latest.found, contains('star'));
    await quiet(tester);
  });

  testWidgets('says a trace too short to count is too short', (tester) async {
    await open(tester);

    await traceWord(tester, [_star[0], _star[1], _star[2]]);

    expect(find.text('too short'), findsOneWidget);
    expect(latest.found, isEmpty);
    await quiet(tester);
  });

  testWidgets('says a word it does not know is not a word', (tester) async {
    await open(tester);

    await traceWord(tester, _staz);

    expect(find.text('STAZ'), findsOneWidget);
    expect(find.text('not a word'), findsOneWidget);
    expect(latest.found, isEmpty);
    await quiet(tester);
  });

  testWidgets('says a word found already is found already', (tester) async {
    await open(tester);

    await traceWord(tester, _star);
    await tester.pump(const Duration(milliseconds: 500));
    await traceWord(tester, _star);

    expect(find.text('already found'), findsOneWidget);
    expect(latest.found, ['star']);
    expect(latest.score, Board.scoreOf('star'));
    await quiet(tester);
  });

  testWidgets('lets the line go quiet again a moment after the thumb lifts',
      (tester) async {
    await open(tester);

    await traceWord(tester, _star);
    expect(find.text('STAR'), findsOneWidget);

    await quiet(tester);
    expect(find.text('STAR'), findsNothing);
    expect(find.text('Trace a word'), findsOneWidget);
  });

  testWidgets('buzzes for every square taken and again once it is a word',
      (tester) async {
    // A thumb covers the square it is on, so the two things worth knowing
    // while a word is being traced arrive through the finger.
    final buzzes = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        buzzes.add('${call.arguments}');
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await open(tester);
    final gesture = await thumbAcross(tester, _star);

    expect(
      buzzes.where((buzz) => buzz.endsWith('selectionClick')).length,
      4,
      reason: 'one for each of the four letters',
    );
    expect(
      buzzes.where((buzz) => buzz.endsWith('mediumImpact')).length,
      1,
      reason: 'and one for the r that turned them into a word',
    );

    await gesture.up();
    await tester.pump();
    await quiet(tester);
  });

  testWidgets('a tap that never moves leaves nothing on the board',
      (tester) async {
    await open(tester);

    final gesture = await tester.startGesture(_middleOf(tester, _star[0]));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('too short'), findsOneWidget);
    expect(latest.found, isEmpty);

    await tester.pump(_settle);
    expectNothingTraced(tester, 'after a tap');
    await quiet(tester);
    expect(find.text('Trace a word'), findsOneWidget);
  });

  testWidgets('a tap between squares is not worth answering', (tester) async {
    await open(tester);

    final gesture = await tester.startGesture(
      betweenSquares(tester, const Spot(1, 1)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump(_settle);

    expect(find.text('Trace a word'), findsOneWidget,
        reason: 'a thumb that took no squares has nothing to be told');
    expectNothingTraced(tester, 'after a tap between squares');
  });

  testWidgets('takes the squares a thumb flung across the board flew over',
      (tester) async {
    await open(tester);

    // One report from the s to the r, which is what a drag faster than the
    // frames looks like by the time it arrives.
    final gesture = await tester.startGesture(_middleOf(tester, _star[0]));
    await gesture.moveTo(_middleOf(tester, _star[3]));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(latest.found, contains('star'));
    await quiet(tester);
  });

  testWidgets('keeps one trace through a thumb that leaves the screen and '
      'comes back', (tester) async {
    await open(tester);

    final gesture = await tester.startGesture(_middleOf(tester, _star[0]));
    await gesture.moveTo(const Offset(-500, -500));
    await tester.pump();
    await gesture.moveTo(_middleOf(tester, _star[1]));
    await gesture.moveTo(_middleOf(tester, _star[2]));
    await gesture.moveTo(_middleOf(tester, _star[3]));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('STAR'), findsOneWidget);
    expect(latest.found, contains('star'));
    await quiet(tester);
  });

  testWidgets('counts a word the system took the thumb away from',
      (tester) async {
    // A call arriving mid-word cancels the pointer. The letters were traced,
    // so they count.
    await open(tester);

    final gesture = await thumbAcross(tester, _star);
    await gesture.cancel();
    await tester.pump();

    expect(latest.found, contains('star'));
    await tester.pump(_settle);
    expectNothingTraced(tester, 'after the pointer was cancelled');
    await quiet(tester);
  });

  testWidgets('ignores a second thumb landing part way through a word',
      (tester) async {
    await open(tester);

    final thumb = await thumbAcross(tester, [_star[0], _star[1]]);

    final other = await tester.startGesture(
      _middleOf(tester, const Spot(2, 0)),
      pointer: 99,
    );
    await other.moveTo(_middleOf(tester, const Spot(2, 1)));
    await tester.pump();
    await other.up();
    await tester.pump();

    expect(find.text('ST'), findsOneWidget);

    await thumb.moveTo(_middleOf(tester, _star[2]));
    await thumb.moveTo(_middleOf(tester, _star[3]));
    await tester.pump();
    await thumb.up();
    await tester.pump();

    expect(latest.found, contains('star'));
    await quiet(tester);
  });
}
