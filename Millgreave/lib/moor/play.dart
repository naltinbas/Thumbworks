import 'moor.dart';
import 'rules.dart';

/// A moor part set: which file holds its mill in which row.
class Play {
  const Play._(this.moor, this.rows, this.before);

  Play.of(Moor moor)
      : this._(moor, List<int>.unmodifiable(List.filled(moor.size, -1)),
            null);

  final Moor moor;

  /// rows[file], -1 while a file stands empty.
  final List<int> rows;

  /// The moor before the last mill went up, or null at the start.
  final Play? before;

  int get standing => rows.where((row) => row >= 0).length;

  bool get isSet => standing == moor.size;

  bool hasMill(int file, int row) => rows[file] == row;

  /// The mill that would steal the wind at a plot, as (file, row), or
  /// null when the plot is clear.
  (int, int)? thiefAt(int file, int row) {
    for (var other = 0; other < moor.size; other++) {
      if (other == file || rows[other] < 0) continue;
      if (Rules.steals(other, rows[other], file, row)) {
        return (other, rows[other]);
      }
    }
    return null;
  }

  /// Whether a mill can go up at a plot: its file empty, its wind clear.
  bool mayRaise(int file, int row) {
    if (isSet || file < 0 || file >= moor.size) return false;
    if (row < 0 || row >= moor.size || rows[file] >= 0) return false;
    return thiefAt(file, row) == null;
  }

  /// Raises a mill. Returns this unchanged when it cannot go up.
  Play raise(int file, int row) {
    if (!mayRaise(file, row)) return this;
    return Play._(
      moor,
      List<int>.unmodifiable([
        for (var at = 0; at < moor.size; at++)
          at == file ? row : rows[at],
      ]),
      this,
    );
  }

  /// The last mill down again, or this at the start.
  Play get back => before ?? this;

  /// Whether the moor can still be fully set from here.
  bool get canStill => Rules.canStillSet(moor.size, [...rows]);

  /// A plot that keeps the moor settable, lowest empty file first, or
  /// null when there is none.
  (int, int)? get next {
    if (isSet) return null;
    for (var file = 0; file < moor.size; file++) {
      if (rows[file] >= 0) continue;
      for (var row = 0; row < moor.size; row++) {
        if (!mayRaise(file, row)) continue;
        final tried = [...rows];
        tried[file] = row;
        if (Rules.canStillSet(moor.size, tried)) return (file, row);
      }
      return null;
    }
    return null;
  }
}
