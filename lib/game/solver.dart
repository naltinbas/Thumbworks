import 'package:collection/collection.dart';

import 'cards.dart';
import 'table.dart';

/// What a search came to.
class Solved {
  const Solved({
    required this.moves,
    required this.looked,
    required this.gaveUp,
  });

  /// The moves that win, or empty if none were found.
  final List<Move> moves;

  /// How many positions were looked at.
  final int looked;

  /// Whether it ran out of patience rather than out of moves. A deal that
  /// gave up is a deal nobody has shown to be unwinnable.
  final bool gaveUp;

  bool get won => moves.isNotEmpty;
}

/// Finds a way to win, or says it could not.
///
/// Best first, not depth first. The first version was depth first with the
/// moves in a sensible order and it solved five deals in forty, spending two
/// hundred thousand positions on each of the rest: a depth first search picks
/// a direction and follows it to the end of the world, and in this game the
/// end of the world is a long way away.
///
/// Best first keeps every position it has reached in a queue ordered by how
/// finished it looks, and always carries on from the most finished one. It
/// does not care how it got there, which is right here — a win is a win
/// however long the line was — and it means a bad guess costs one position
/// rather than a hundred thousand.
///
/// Two other things do most of the remaining work. Positions are recognised by
/// a fingerprint that ignores which cell a card is in and which order two
/// identical columns are written in, because those are the same position
/// wearing different hats. And every position is tidied first: anything that
/// can go home without ever being wanted back is sent up before anything else
/// is considered, which collapses whole branches into one.
class Solver {
  const Solver({this.mostPositions = 200000});

  /// How many positions to look at before giving up.
  ///
  /// A bound rather than a target. What it really stops is a bug turning into
  /// a phone that never answers.
  final int mostPositions;

  Solved solve(Table from) {
    final start = from.tidied;
    if (start.isWon) {
      return const Solved(moves: [], looked: 1, gaveUp: false);
    }

    final queue = HeapPriorityQueue<_Step>((a, b) => a.score - b.score);
    final seen = <String>{start.fingerprint};
    queue.add(_Step(table: start, from: null, move: null, score: _score(start)));

    var looked = 0;
    while (queue.isNotEmpty && looked < mostPositions) {
      final step = queue.removeFirst();
      looked++;

      for (final move in step.table.moves) {
        final next = step.table.play(move).tidied;
        if (next.isWon) {
          return Solved(
            moves: _pathTo(_Step(table: next, from: step, move: move, score: 0)),
            looked: looked,
            gaveUp: false,
          );
        }
        if (!seen.add(next.fingerprint)) continue;
        queue.add(_Step(
          table: next,
          from: step,
          move: move,
          score: _score(next),
        ));
      }
    }

    return Solved(
      moves: const [],
      looked: looked,
      gaveUp: looked >= mostPositions,
    );
  }

  /// How unfinished a position looks. Smaller is better.
  ///
  /// Three terms, and the weights are the whole of the tuning. Cards not yet
  /// home is the goal itself and counts most. Cards lying on top of the one a
  /// foundation wants next is how much digging is left, which is the thing
  /// that actually decides these games. Occupied cells count a little,
  /// because a position with four cards parked is a position with no room to
  /// think.
  static int _score(Table table) =>
      (52 - table.homeCount) * 3 + table.buried * 2 + (4 - table.freeCells);

  static List<Move> _pathTo(_Step end) {
    final moves = <Move>[];
    _Step? at = end;
    while (at != null && at.move != null) {
      moves.add(at.move!);
      at = at.from;
    }
    return moves.reversed.toList();
  }
}

/// One position in the queue, and how it was reached.
class _Step {
  const _Step({
    required this.table,
    required this.from,
    required this.move,
    required this.score,
  });

  final Table table;
  final _Step? from;
  final Move? move;
  final int score;
}

/// The next move on a line that wins, or null if there is not one to be had.
///
/// This is what the hint button gives, and it is the reason the solver is in
/// the app at all rather than only in a test. A hint that suggests a move
/// because it looks reasonable is a hint that can walk a player into a dead
/// end; this one is a move on a proved path to a finished game.
Move? hintFor(Table table, {Solver solver = const Solver()}) {
  final tidy = table.tidied;
  if (tidy.isWon) return null;

  // If tidying alone does something, that is the hint: it is always safe and
  // it is what a player should do before thinking about anything else.
  if (tidy.fingerprint != table.fingerprint) {
    for (final move in table.moves) {
      if (move.to != Where.home) continue;
      return move;
    }
  }

  final found = solver.solve(table);
  return found.won ? found.moves.first : null;
}

/// Which card a move picks up, for a screen that wants to say so.
Card? movedCard(Table table, Move move) => switch (move.from) {
      Where.cell => table.cell(move.fromAt),
      Where.column => table.column(move.fromAt).isEmpty
          ? null
          : table.column(move.fromAt)[
              table.column(move.fromAt).length - move.cards],
      Where.home => null,
    };
