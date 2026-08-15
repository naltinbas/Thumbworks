/// A slate: nine cells, nought for empty, one for a cross, two for a
/// nought. Crosses move first.
typedef Board = List<int>;

/// The law of noughts and crosses, and the whole tree of it.
class Rules {
  static const cross = 1;
  static const nought = 2;

  static const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static const corners = [0, 2, 6, 8];
  static const sides = [1, 3, 5, 7];
  static const centre = 4;

  static Board get empty => List.filled(9, 0);

  /// The mark with three in a row, or nought.
  static int winner(Board b) {
    for (final line in lines) {
      final m = b[line[0]];
      if (m != 0 && m == b[line[1]] && m == b[line[2]]) return m;
    }
    return 0;
  }

  /// The winning line, or null.
  static List<int>? winningLine(Board b) {
    for (final line in lines) {
      final m = b[line[0]];
      if (m != 0 && m == b[line[1]] && m == b[line[2]]) return line;
    }
    return null;
  }

  static bool full(Board b) => !b.contains(0);

  static bool over(Board b) => winner(b) != 0 || full(b);

  static int count(Board b, int mark) => b.where((c) => c == mark).length;

  /// Whose turn: crosses when the counts are level.
  static int toMove(Board b) => count(b, cross) == count(b, nought) ? cross : nought;

  static List<int> empties(Board b) => [for (var c = 0; c < 9; c++) if (b[c] == 0) c];

  static Board played(Board b, int cell, int mark) {
    final next = List.of(b);
    next[cell] = mark;
    return next;
  }

  /// The slate as one number, base three.
  static int code(Board b) {
    var n = 0;
    for (var c = 8; c >= 0; c--) {
      n = n * 3 + b[c];
    }
    return n;
  }

  /// Cells where [mark] would make three in a row at once.
  static List<int> winningCells(Board b, int mark) => [
        for (final c in empties(b))
          if (winner(played(b, c, mark)) == mark) c,
      ];

  /// Cells where [mark] would have two ways to win next move.
  static List<int> forkCells(Board b, int mark) => [
        for (final c in empties(b))
          if (winningCells(played(b, c, mark), mark).length >= 2) c,
      ];

  static final _values = <int, int>{};

  /// The tree's word on the slate, for the side to move: one for a
  /// forced win, nought for level, minus one for a forced loss.
  static int value(Board b) {
    final key = code(b);
    final known = _values[key];
    if (known != null) return known;
    int found;
    final won = winner(b);
    if (won != 0) {
      // The side to move did not make it, so it lost.
      found = -1;
    } else if (full(b)) {
      found = 0;
    } else {
      final me = toMove(b);
      var best = -2;
      for (final c in empties(b)) {
        final v = -value(played(b, c, me));
        if (v > best) best = v;
        if (best == 1) break;
      }
      found = best;
    }
    _values[key] = found;
    return found;
  }

  /// The moves that keep the tree's word.
  static List<int> bestMoves(Board b) {
    final me = toMove(b);
    final v = value(b);
    return [for (final c in empties(b)) if (-value(played(b, c, me)) == v) c];
  }

  /// Every game played out from [start], move by move, both sides
  /// free: how many, who won, and how long they ran.
  static Census census([Board? start]) {
    final census = Census();
    void walk(Board b, int depth) {
      census.positions.add(code(b));
      final won = winner(b);
      if (won != 0 || full(b)) {
        census.games++;
        if (won == cross) census.crossWins++;
        if (won == nought) census.noughtWins++;
        if (won == 0) census.draws++;
        census.byLength[depth] = (census.byLength[depth] ?? 0) + 1;
        return;
      }
      final me = toMove(b);
      for (final c in empties(b)) {
        walk(played(b, c, me), depth + 1);
      }
    }

    walk(start ?? empty, start == null ? 0 : 9 - empties(start).length);
    return census;
  }
}

/// What the walk of the tree found.
class Census {
  final positions = <int>{};
  var games = 0;
  var crossWins = 0;
  var noughtWins = 0;
  var draws = 0;
  final byLength = <int, int>{};
}
