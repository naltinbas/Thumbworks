/// The law of the plot.
///
/// A plot is a little grid to shade. Each row and column carries a
/// tally: the lengths of its runs of shade, in order. The plot is done
/// when every cell is decided and every line keeps its tally.
///
/// The game's standing claim is that the tallies name one picture, and
/// nothing takes it on trust: an enumeration tries every filling of
/// the rows, and a line-solver reaches the picture by deduction alone,
/// two ways that share nothing.
class Rules {
  Rules(this.wide, this.high);

  final int wide;
  final int high;

  /// Every way one line of a given length holds its runs, as bitmasks.
  static List<int> patterns(List<int> tally, int length) {
    if (tally.isEmpty || tally.first == 0) return [0];
    final out = <int>[];
    _place(tally, 0, 0, 0, length, out);
    return out;
  }

  static void _place(List<int> tally, int at, int from, int laid,
      int length, List<int> out) {
    if (at == tally.length) {
      out.add(laid);
      return;
    }
    final run = tally[at];
    final rest = [
      for (var later = at + 1; later < tally.length; later++)
        tally[later],
    ];
    final restNeeds =
        rest.isEmpty ? 0 : rest.reduce((a, b) => a + b) + rest.length;
    for (var start = from; start + run + restNeeds <= length; start++) {
      final mask = ((1 << run) - 1) << start;
      _place(tally, at + 1, start + run + 1, laid | mask, length, out);
    }
  }

  /// The tally a finished line shows.
  static List<int> tallyOf(int line, int length) {
    final runs = <int>[];
    var run = 0;
    for (var at = 0; at < length; at++) {
      if (line & (1 << at) != 0) {
        run++;
      } else if (run > 0) {
        runs.add(run);
        run = 0;
      }
    }
    if (run > 0) runs.add(run);
    return runs.isEmpty ? const [0] : runs;
  }

  /// Every picture the tallies accept, row filling by row filling,
  /// columns pruned as the rows stack. Capped, since past a few the
  /// only fact that matters is "more than one".
  List<List<int>> solutionsOf(
      List<List<int>> rowTallies, List<List<int>> colTallies,
      {int cap = 4}) {
    final rowChoices = [
      for (final tally in rowTallies) patterns(tally, wide),
    ];
    final colChoices = [
      for (final tally in colTallies) patterns(tally, high),
    ];
    final found = <List<int>>[];
    _stack(rowChoices, colChoices, <int>[], found, cap);
    return found;
  }

  void _stack(List<List<int>> rowChoices, List<List<int>> colChoices,
      List<int> laid, List<List<int>> found, int cap) {
    if (found.length >= cap) return;
    final depth = laid.length;
    if (depth == high) {
      found.add([...laid]);
      return;
    }
    for (final row in rowChoices[depth]) {
      laid.add(row);
      if (_columnsCanStand(colChoices, laid)) {
        _stack(rowChoices, colChoices, laid, found, cap);
      }
      laid.removeLast();
    }
  }

  bool _columnsCanStand(List<List<int>> colChoices, List<int> laid) {
    for (var col = 0; col < wide; col++) {
      var prefix = 0;
      for (var row = 0; row < laid.length; row++) {
        if (laid[row] & (1 << col) != 0) prefix |= 1 << row;
      }
      final mask = (1 << laid.length) - 1;
      var any = false;
      for (final pattern in colChoices[col]) {
        if (pattern & mask == prefix) {
          any = true;
          break;
        }
      }
      if (!any) return false;
    }
    return true;
  }

  /// One round of deduction over every line: cells every fitting
  /// pattern agrees on become known. Returns the tightened marks, or
  /// null when some line fits nothing.
  ///
  /// Marks are two grids of bits: surely shaded, surely bare.
  (List<int>, List<int>)? deduce(
    List<List<int>> rowTallies,
    List<List<int>> colTallies,
    List<int> shaded,
    List<int> bare,
  ) {
    final nextShaded = [...shaded];
    final nextBare = [...bare];

    for (var row = 0; row < high; row++) {
      final fits = [
        for (final pattern in patterns(rowTallies[row], wide))
          if (pattern & nextShaded[row] == nextShaded[row] &&
              pattern & nextBare[row] == 0)
            pattern,
      ];
      if (fits.isEmpty) return null;
      var all = (1 << wide) - 1;
      var any = 0;
      for (final pattern in fits) {
        all &= pattern;
        any |= pattern;
      }
      nextShaded[row] |= all;
      nextBare[row] |= ((1 << wide) - 1) & ~any;
    }

    for (var col = 0; col < wide; col++) {
      var colShaded = 0;
      var colBare = 0;
      for (var row = 0; row < high; row++) {
        if (nextShaded[row] & (1 << col) != 0) colShaded |= 1 << row;
        if (nextBare[row] & (1 << col) != 0) colBare |= 1 << row;
      }
      final fits = [
        for (final pattern in patterns(colTallies[col], high))
          if (pattern & colShaded == colShaded && pattern & colBare == 0)
            pattern,
      ];
      if (fits.isEmpty) return null;
      var all = (1 << high) - 1;
      var any = 0;
      for (final pattern in fits) {
        all &= pattern;
        any |= pattern;
      }
      for (var row = 0; row < high; row++) {
        if (all & (1 << row) != 0) nextShaded[row] |= 1 << col;
        if (((1 << high) - 1) & ~any & (1 << row) != 0) {
          nextBare[row] |= 1 << col;
        }
      }
    }

    return (nextShaded, nextBare);
  }

  /// Deduces to the fixed point from nothing. The picture, when the
  /// tallies give themselves up to reason alone; null on a
  /// contradiction; a partial pair otherwise.
  (List<int>, List<int>)? lineSolve(
      List<List<int>> rowTallies, List<List<int>> colTallies) {
    var shaded = List<int>.filled(high, 0);
    var bare = List<int>.filled(high, 0);
    while (true) {
      final tightened = deduce(rowTallies, colTallies, shaded, bare);
      if (tightened == null) return null;
      final (nextShaded, nextBare) = tightened;
      var moved = false;
      for (var row = 0; row < high; row++) {
        if (nextShaded[row] != shaded[row] ||
            nextBare[row] != bare[row]) {
          moved = true;
        }
      }
      shaded = nextShaded;
      bare = nextBare;
      if (!moved) return (shaded, bare);
    }
  }

  /// Whether marks decide every cell.
  bool complete(List<int> shaded, List<int> bare) {
    for (var row = 0; row < high; row++) {
      if ((shaded[row] | bare[row]) != (1 << wide) - 1) return false;
    }
    return true;
  }
}
