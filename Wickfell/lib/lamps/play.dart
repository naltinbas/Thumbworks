import 'grid.dart';
import 'levels.dart';
import 'solve.dart';

/// A board in progress.
///
/// Immutable. Which lamps are lit is one number, so a whole game is a list of
/// numbers and taking a press back is dropping the last of them.
class Play {
  const Play._(this.level, this.grid, this.sums, this.boards);

  factory Play.of(Level level, Sums sums) =>
      Play._(level, sums.grid, sums, [level.lit]);

  final Level level;
  final Grid grid;
  final Sums sums;

  /// Every board so far, the first being the one it started on.
  final List<int> boards;

  int get board => boards.last;

  int get pressed => boards.length - 1;

  bool get isDone => board == 0;

  int get lit => grid.litOn(board);

  /// The fewest presses still needed from here.
  ///
  /// Exact, and not a search: it is the answer to a set of linear equations,
  /// worked out fresh from wherever the board has got to.
  int get left => sums.answer(board).fewest;

  /// Whether the presses so far are on a shortest way to putting them out.
  ///
  /// Pressing the same lamp twice is the same as never pressing it, so a
  /// player who has pressed four and needs five on a board of seven has been
  /// somewhere the shortest way does not go. Saying so at once is the
  /// difference between a puzzle and a game of whack-a-mole.
  bool get onShortest => pressed + left == level.presses;

  int get wasted => pressed + left - level.presses;

  /// This board with a lamp pressed.
  Play press(int at) {
    if (isDone) return this;
    return Play._(level, grid, sums, [...boards, grid.pressed(board, at)]);
  }

  /// This board with the last press taken back.
  Play get back => boards.length < 2
      ? this
      : Play._(level, grid, sums, boards.sublist(0, boards.length - 1));

  Play get again => Play._(level, grid, sums, [level.lit]);

  /// A lamp to press next, on a shortest way from here.
  int? get nextPress {
    final answer = sums.answer(board);
    return answer.presses.isEmpty ? null : answer.presses.first;
  }
}
