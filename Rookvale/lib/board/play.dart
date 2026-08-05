import 'board.dart';
import 'puzzles.dart';
import 'solve.dart';

/// A puzzle in progress: the board now, and every board it has been.
///
/// Immutable. Keeping the whole run of boards rather than a stack of moves is
/// what makes taking one back a matter of dropping the last of them.
class Play {
  const Play._(this.puzzle, this.boards);

  factory Play.of(Puzzle puzzle) => Play._(puzzle, [puzzle.board]);

  final Puzzle puzzle;

  /// Every board so far, the first being the one it started on.
  final List<Board> boards;

  Board get board => boards.last;

  int get taken => boards.length - 1;

  bool get isDone => board.isDone;

  /// Whether there is nothing left to take and more than one piece standing.
  bool get isStuck => board.isStuck;

  bool get isOver => isDone || isStuck;

  /// This puzzle after a capture.
  Play after(Move move) {
    if (isOver) return this;
    final next = board.after(move);
    if (next.sameness == board.sameness) return this;
    return Play._(puzzle, [...boards, next]);
  }

  /// This puzzle with the last capture taken back.
  Play get back =>
      boards.length < 2 ? this : Play._(puzzle, boards.sublist(0, boards.length - 1));

  Play get again => Play._(puzzle, [puzzle.board]);

  /// Whether the puzzle can still be finished from here.
  ///
  /// Exact rather than a guess: the whole tree from this board is walked, and
  /// it is small — there are as many captures left as there are pieces.
  bool get canStillBeDone => waysThrough(board).canBeDone;

  /// The capture to make next, if there is one that finishes.
  Move? get nextTake {
    final ways = waysThrough(board);
    return ways.first.isEmpty ? null : ways.first.first;
  }
}
