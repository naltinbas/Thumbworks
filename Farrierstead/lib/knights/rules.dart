/// The law of the knights on an n by n board.
///
/// Squares are numbered row by row from the top left, so square c is
/// on rank c ~/ n and file c % n. A knight on a square attacks the
/// squares two along and one across from it, and two knights attack
/// each other exactly when one stands a knight's move from the other.
class Rules {
  const Rules(this.size);

  /// Squares along a side.
  final int size;

  int get squares => size * size;

  int rank(int c) => c ~/ size;

  int file(int c) => c % size;

  int at(int rank, int file) => rank * size + file;

  static const _leaps = [(1, 2), (2, 1), (-1, 2), (-2, 1), (1, -2), (2, -1), (-1, -2), (-2, -1)];

  /// The squares a knight on [c] attacks.
  List<int> attacks(int c) => [
        for (final (dr, df) in _leaps)
          if (rank(c) + dr >= 0 && rank(c) + dr < size && file(c) + df >= 0 && file(c) + df < size)
            at(rank(c) + dr, file(c) + df),
      ];

  /// Every pair among [knights] where one attacks the other, the lower
  /// square first, in square order.
  List<(int, int)> clashes(Iterable<int> knights) {
    final set = knights.toSet();
    return [
      for (final a in set.toList()..sort())
        for (final b in attacks(a)..sort())
          if (b > a && set.contains(b)) (a, b),
    ];
  }

  /// Whether [knights] are [count] strong and none attacks another.
  bool lands(Iterable<int> knights, int count) => knights.length == count && clashes(knights).isEmpty;

  /// The walk: every setting of [count] knights taken square by square,
  /// a knight set or not, dropping any setting where two attack or too
  /// few squares are left to make the count; how many stand.
  int walk(int count) {
    final taken = List.filled(squares, false);
    var standing = 0;
    void go(int c, int placed) {
      if (placed == count) {
        standing++;
        return;
      }
      if (c >= squares || placed + (squares - c) < count) return;
      var free = true;
      for (final a in attacks(c)) {
        if (taken[a]) {
          free = false;
          break;
        }
      }
      if (free) {
        taken[c] = true;
        go(c + 1, placed + 1);
        taken[c] = false;
      }
      go(c + 1, placed);
    }

    go(0, 0);
    return standing;
  }

  /// The sweep, taken whole: every one of the choose(squares, count)
  /// settings held up in turn, no dropping, and (standing, all) counted.
  /// For the small boards, where that is bearable.
  (int, int) sweep(int count) {
    var standing = 0, all = 0;
    final chosen = <int>[];
    void go(int from, int left) {
      if (left == 0) {
        all++;
        if (clashes(chosen).isEmpty) standing++;
        return;
      }
      for (var c = from; c <= squares - left; c++) {
        chosen.add(c);
        go(c + 1, left - 1);
        chosen.removeLast();
      }
    }

    go(0, count);
    return (standing, all);
  }

  /// choose(squares, count): every setting, told without the sweep.
  int settings(int count) => choose(squares, count);

  static int choose(int n, int k) {
    if (k < 0 || k > n) return 0;
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }

  /// The pairing: the squares paired off as knight's moves, as many
  /// pairs as can be, found by growing the pairing a path at a time.
  /// Each pair holds at most one knight, and a square left over one,
  /// so the most knights that stand is the squares less the pairs.
  List<(int, int)> get pairing {
    final mate = List<int?>.filled(squares, null);
    bool grow(int c, Set<int> seen) {
      for (final b in attacks(c)) {
        if (!seen.add(b)) continue;
        if (mate[b] == null || grow(mate[b]!, seen)) {
          mate[b] = c;
          mate[c] = b;
          return true;
        }
      }
      return false;
    }

    // Grow from the light squares only: a knight always changes colour,
    // so every pair is one light square and one dark, and growing from
    // one side finds every path there is.
    for (var c = 0; c < squares; c++) {
      if ((rank(c) + file(c)).isEven && mate[c] == null) grow(c, {});
    }
    return [
      for (var c = 0; c < squares; c++)
        if (mate[c] != null && mate[c]! > c) (c, mate[c]!),
    ];
  }

  /// The most knights that can stand, by the pairing: squares less pairs.
  int get bound => squares - pairing.length;

  /// The squares of one colour, the corners' colour: a knight always
  /// lands on the other colour, so none of these attacks another, and
  /// they are half the board rounded up.
  List<int> get oneColour => [
        for (var c = 0; c < squares; c++)
          if ((rank(c) + file(c)).isEven) c,
      ];
}
