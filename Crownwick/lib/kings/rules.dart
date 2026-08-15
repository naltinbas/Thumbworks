/// The law of the kings on an n by n board.
///
/// Squares are numbered row by row from the top left, so square c is
/// on rank c ~/ n and file c % n. A king on a square attacks the eight
/// squares round it, and two kings attack each other exactly when they
/// stand side by side, one above the other, or corner to corner.
class Rules {
  const Rules(this.size);

  /// Squares along a side.
  final int size;

  int get squares => size * size;

  int rank(int c) => c ~/ size;

  int file(int c) => c % size;

  int at(int rank, int file) => rank * size + file;

  /// The squares a king on [c] attacks.
  List<int> attacks(int c) => [
        for (var dr = -1; dr <= 1; dr++)
          for (var df = -1; df <= 1; df++)
            if ((dr != 0 || df != 0) &&
                rank(c) + dr >= 0 &&
                rank(c) + dr < size &&
                file(c) + df >= 0 &&
                file(c) + df < size)
              at(rank(c) + dr, file(c) + df),
      ];

  /// Every pair among [kings] where one attacks the other, the lower
  /// square first, in square order.
  List<(int, int)> clashes(Iterable<int> kings) {
    final set = kings.toSet();
    return [
      for (final a in set.toList()..sort())
        for (final b in attacks(a)..sort())
          if (b > a && set.contains(b)) (a, b),
    ];
  }

  /// Whether [kings] are [count] strong and none attacks another.
  bool lands(Iterable<int> kings, int count) => kings.length == count && clashes(kings).isEmpty;

  /// The walk: every setting of [count] kings taken square by square, a
  /// king set or not, dropping any setting where two attack or too few
  /// squares are left to make the count; how many stand.
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

  /// The blocks: the board cut into two-by-two blocks from the top left,
  /// the last row and file making blocks of two or one when the side is
  /// odd. Every square is in exactly one block, and two kings in one
  /// block attack each other, so at most one king stands in each.
  List<List<int>> get blocks => [
        for (var r = 0; r < size; r += 2)
          for (var f = 0; f < size; f += 2)
            [
              for (var dr = 0; dr < 2 && r + dr < size; dr++)
                for (var df = 0; df < 2 && f + df < size; df++) at(r + dr, f + df),
            ],
      ];

  /// The most kings that can stand, by the blocks: one apiece.
  int get bound => blocks.length;

  /// The even squares, even rank and even file: no two touch, and there
  /// is one in every block.
  List<int> get evens => [
        for (var c = 0; c < squares; c++)
          if (rank(c).isEven && file(c).isEven) c,
      ];
}
