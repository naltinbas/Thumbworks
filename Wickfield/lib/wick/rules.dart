/// The algebra of the lamps.
///
/// A board is a bitmask over rows by columns, bit r * cols + c lit when
/// the lamp there is. Pressing a lamp flips it and its four neighbours,
/// which over two-element arithmetic makes the whole game one linear
/// question: which sums of crosses make this board? Everything below is
/// that question asked carefully, and none of it is trusted anywhere
/// without a sweep or an executed answer standing beside it.
class Rules {
  Rules(this.rows, this.cols) {
    _crosses = List.generate(rows * cols, _cross);
    _elimination();
  }

  final int rows;
  final int cols;

  int get cells => rows * cols;

  /// The cross each press flips, one mask per cell.
  late final List<int> _crosses;

  /// The reduced rows: (lamps made, presses making them), each led by a
  /// lamp bit no other row carries. And the quiet patterns: press-sets
  /// that make no lamp at all.
  final List<(int, int)> _rows = [];
  final List<int> quiet = [];

  int _cross(int cell) {
    final row = cell ~/ cols;
    final col = cell % cols;
    var mask = 1 << cell;
    if (row > 0) mask |= 1 << (cell - cols);
    if (row < rows - 1) mask |= 1 << (cell + cols);
    if (col > 0) mask |= 1 << (cell - 1);
    if (col < cols - 1) mask |= 1 << (cell + 1);
    return mask;
  }

  int crossOf(int cell) => _crosses[cell];

  /// One press, board in, board out.
  int press(int board, int cell) => board ^ _crosses[cell];

  /// A whole press-set at once.
  int pressAll(int board, int presses) {
    var out = board;
    for (var cell = 0; cell < cells; cell++) {
      if (presses & (1 << cell) != 0) out = press(out, cell);
    }
    return out;
  }

  static int weigh(int mask) {
    var weight = 0;
    for (var bits = mask; bits != 0; bits &= bits - 1) {
      weight++;
    }
    return weight;
  }

  /// Reduces the press matrix once, all the way: after this every kept
  /// row is led by a lamp bit that appears in no other row, so deciding
  /// a board is one pass over the rows with nothing left to sneak back.
  void _elimination() {
    final working = <(int, int)>[
      for (var cell = 0; cell < cells; cell++) (_crosses[cell], 1 << cell),
    ];

    var rank = 0;
    for (var lamp = 0; lamp < cells; lamp++) {
      final bit = 1 << lamp;
      var found = -1;
      for (var at = rank; at < working.length; at++) {
        if (working[at].$1 & bit != 0) {
          found = at;
          break;
        }
      }
      if (found < 0) continue;
      final row = working[found];
      working[found] = working[rank];
      working[rank] = row;
      for (var at = 0; at < working.length; at++) {
        if (at == rank || working[at].$1 & bit == 0) continue;
        working[at] = (working[at].$1 ^ row.$1, working[at].$2 ^ row.$2);
      }
      rank++;
    }

    for (var at = 0; at < working.length; at++) {
      if (at < rank) {
        _rows.add(working[at]);
      } else if (working[at].$2 != 0) {
        quiet.add(working[at].$2);
      }
    }
  }

  /// One press-set that darkens the board, or null if none does.
  int? answer(int board) {
    var want = board;
    var presses = 0;
    for (final (made, pressed) in _rows) {
      final lead = made & -made;
      if (want & lead == 0) continue;
      want ^= made;
      presses ^= pressed;
    }
    return want == 0 ? presses : null;
  }

  /// Every press-set that darkens the board: the answer shifted by every
  /// sum of quiet patterns.
  List<int> answers(int board) {
    final one = answer(board);
    if (one == null) return const [];
    var all = [one];
    for (final pattern in quiet) {
      all = [...all, for (final so in all) so ^ pattern];
    }
    return all;
  }

  /// The fewest presses that darken the board, or null.
  int? fewest(int board) {
    final all = answers(board);
    if (all.isEmpty) return null;
    var least = weigh(all.first);
    for (final presses in all) {
      final weight = weigh(presses);
      if (weight < least) least = weight;
    }
    return least;
  }

  /// A lightest press-set, or null.
  int? lightest(int board) {
    final all = answers(board);
    if (all.isEmpty) return null;
    var best = all.first;
    for (final presses in all) {
      if (weigh(presses) < weigh(best)) best = presses;
    }
    return best;
  }

  /// Whether the board can go dark at all.
  bool solvable(int board) => answer(board) != null;

  /// How many lit lamps stand on a pattern.
  int overlap(int board, int pattern) => weigh(board & pattern);

  /// The quiet pattern this board falls odd against, or null if it sits
  /// even with every one. Odd is a death certificate: a press flips an
  /// even count of any quiet pattern's lamps, so the parity never moves,
  /// and dark needs it even.
  int? oddAgainst(int board) {
    for (final pattern in quiet) {
      if (overlap(board, pattern).isOdd) return pattern;
    }
    return null;
  }

  /// Every board there is, small sides only.
  Iterable<int> allBoards() sync* {
    for (var board = 0; board < (1 << cells); board++) {
      yield board;
    }
  }

  /// The fewest presses for every board, walked breadth-first from dark
  /// with no algebra anywhere in it. Small sides only.
  List<int?> byWalk() {
    final distance = List<int?>.filled(1 << cells, null);
    distance[0] = 0;
    var edge = [0];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final board in edge) {
        for (var cell = 0; cell < cells; cell++) {
          final there = press(board, cell);
          if (distance[there] != null) continue;
          distance[there] = distance[board]! + 1;
          next.add(there);
        }
      }
      edge = next;
    }
    return distance;
  }
}
