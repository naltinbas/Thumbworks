import 'plot.dart';
import 'rules.dart';

/// A plot being shaded. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.plot, this.rules, this.shaded, this.bare, this.marks,
      this.before);

  Play.of(Plot plot)
      : this._(plot, Rules(plot.wide, plot.high),
            List<int>.filled(plot.high, 0),
            List<int>.filled(plot.high, 0), 0, null);

  final Plot plot;
  final Rules rules;

  /// What the hand has decided: surely shaded, surely bare.
  final List<int> shaded;
  final List<int> bare;

  /// Marks made so far.
  final int marks;

  final Play? before;

  bool isShaded(int row, int col) => shaded[row] & (1 << col) != 0;
  bool isBare(int row, int col) => bare[row] & (1 << col) != 0;

  /// Taps cycle a cell: unknown, shaded, bare, unknown.
  Play touch(int row, int col) {
    if (row < 0 || col < 0 || row >= plot.high || col >= plot.wide) {
      return this;
    }
    if (isDone) return this;
    final bit = 1 << col;
    final nextShaded = [...shaded];
    final nextBare = [...bare];
    if (isShaded(row, col)) {
      nextShaded[row] &= ~bit;
      nextBare[row] |= bit;
    } else if (isBare(row, col)) {
      nextBare[row] &= ~bit;
    } else {
      nextShaded[row] |= bit;
    }
    return Play._(plot, rules, nextShaded, nextBare, marks + 1, this);
  }

  Play get back => before ?? this;

  int colLine(List<int> grid, int col) {
    var line = 0;
    for (var row = 0; row < plot.high; row++) {
      if (grid[row] & (1 << col) != 0) line |= 1 << row;
    }
    return line;
  }

  /// Whether a row's marks still fit some pattern of its tally.
  bool rowStands(int row) {
    for (final pattern
        in Rules.patterns(plot.rowTallies[row], plot.wide)) {
      if (pattern & shaded[row] == shaded[row] &&
          pattern & bare[row] == 0) {
        return true;
      }
    }
    return false;
  }

  bool colStands(int col) {
    final colShaded = colLine(shaded, col);
    final colBare = colLine(bare, col);
    for (final pattern
        in Rules.patterns(plot.colTallies[col], plot.high)) {
      if (pattern & colShaded == colShaded && pattern & colBare == 0) {
        return true;
      }
    }
    return false;
  }

  /// The lines whose marks fit nothing now.
  List<int> get fallenRows => [
        for (var row = 0; row < plot.high; row++)
          if (!rowStands(row)) row,
      ];

  List<int> get fallenCols => [
        for (var col = 0; col < plot.wide; col++)
          if (!colStands(col)) col,
      ];

  /// Whether every cell is decided and every tally kept.
  bool get isDone {
    for (var row = 0; row < plot.high; row++) {
      if ((shaded[row] | bare[row]) != (1 << plot.wide) - 1) {
        return false;
      }
      if (Rules.tallyOf(shaded[row], plot.wide).join(',') !=
          plot.rowTallies[row].join(',')) {
        return false;
      }
    }
    for (var col = 0; col < plot.wide; col++) {
      if (Rules.tallyOf(colLine(shaded, col), plot.high).join(',') !=
          plot.colTallies[col].join(',')) {
        return false;
      }
    }
    return true;
  }

  /// How many cells stand decided.
  int get decided {
    var count = 0;
    for (var row = 0; row < plot.high; row++) {
      var bits = shaded[row] | bare[row];
      while (bits != 0) {
        bits &= bits - 1;
        count++;
      }
    }
    return count;
  }

  /// A cell one round of deduction can decide from what stands, with
  /// how sure it is: (row, col, shade?). Null when nothing new comes,
  /// or the marks have fallen.
  (int, int, bool)? get next {
    if (fallenRows.isNotEmpty || fallenCols.isNotEmpty) return null;
    final tightened =
        rules.deduce(plot.rowTallies, plot.colTallies, shaded, bare);
    if (tightened == null) return null;
    final (nextShaded, nextBare) = tightened;
    for (var row = 0; row < plot.high; row++) {
      for (var col = 0; col < plot.wide; col++) {
        final bit = 1 << col;
        if (nextShaded[row] & bit != 0 && shaded[row] & bit == 0) {
          return (row, col, true);
        }
        if (nextBare[row] & bit != 0 && bare[row] & bit == 0) {
          return (row, col, false);
        }
      }
    }
    return null;
  }
}
