import 'level.dart';
import 'rules.dart';

/// A rail being sorted. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.row, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, List.of(level.row), 0, null);

  /// A play stood at a row, for the mark and the tests.
  factory Play.standing(Level level, List<int> row, int moves) => Play._(level, List.of(row), moves, null);

  final Level level;

  /// The coats on the hooks as they hang.
  final List<int> row;

  /// Swaps made, counted.
  final int moves;

  final Play? before;

  int get inversions => Rules.inversions(row);

  bool get sorted => Rules.sorted(row);

  int get left => level.swaps - moves;

  bool get isDone => sorted && moves == level.swaps;

  /// The swaps spent and the row not sorted: over, not landed.
  bool get missed => moves == level.swaps && !sorted;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  bool touches(int i) => !isOver && i >= 0 && i + 1 < row.length;

  /// Swaps hooks [i] and [i + 1].
  Play tap(int i) {
    if (!touches(i)) return this;
    return Play._(level, Rules.swapped(row, i), moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('swap', hook) for the first descent,
  /// which mends one pair; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    // Only a swap that mends a pair keeps the sort within the count.
    if (inversions != left) return null;
    final d = Rules.firstDescent(row);
    return d == null ? null : ('swap', d);
  }
}
