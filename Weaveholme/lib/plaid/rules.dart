/// The law of the plaid: n rows of n squares, light or dark, and every
/// two rows to agree in exactly half their squares. A row is kept as
/// bits, the square in column c the bit c, dark for set.
class Rules {
  const Rules(this.size);

  /// Rows and columns.
  final int size;

  int get half => size ~/ 2;

  static bool dark(int row, int c) => (row >> c) & 1 == 1;

  /// In how many squares rows [a] and [b] agree.
  int agree(int a, int b) {
    var n = 0;
    for (var c = 0; c < size; c++) {
      if (dark(a, c) == dark(b, c)) n++;
    }
    return n;
  }

  /// Whether rows [a] and [b] agree in exactly half.
  bool even(int a, int b) => agree(a, b) == half;

  /// The pairs of rows in [rows] that do not agree in half, as (i, j).
  List<(int, int)> uneven(List<int> rows) => [
        for (var i = 0; i < rows.length; i++)
          for (var j = i + 1; j < rows.length; j++)
            if (!even(rows[i], rows[j])) (i, j),
      ];

  /// Whether every two rows agree in half.
  bool lands(List<int> rows) => rows.length == size && uneven(rows).isEmpty;

  /// The sweep: every filling of the plaid held up, 2 to the n squared
  /// of them, and (landing, all) counted. For the two and the four.
  (int, int) sweep() {
    final total = 1 << (size * size);
    var landing = 0;
    for (var m = 0; m < total; m++) {
      final rows = [for (var r = 0; r < size; r++) (m >> (r * size)) & ((1 << size) - 1)];
      if (uneven(rows).isEmpty) landing++;
    }
    return (landing, total);
  }

  /// The walk: every completion of the rows [given] to the whole plaid,
  /// row by row, each new row held against every row above it; how
  /// many land, and the first found.
  (int, List<int>?) walk(List<int> given) {
    var count = 0;
    List<int>? first;
    void go(List<int> rows) {
      if (rows.length == size) {
        count++;
        first ??= List.of(rows);
        return;
      }
      for (var cand = 0; cand < (1 << size); cand++) {
        var ok = true;
        for (final r in rows) {
          if (!even(r, cand)) {
            ok = false;
            break;
          }
        }
        if (ok) go([...rows, cand]);
      }
    }

    go(List.of(given));
    return (count, first);
  }

  /// Every triple of rows of the plaid's width that agree pairwise in
  /// half: (triples, all).
  (int, int) triples() {
    final all = 1 << size;
    var found = 0;
    for (var a = 0; a < all; a++) {
      for (var b = 0; b < all; b++) {
        if (!even(a, b)) continue;
        for (var c = 0; c < all; c++) {
          if (even(a, c) && even(b, c)) found++;
        }
      }
    }
    return (found, all * all * all);
  }

  /// Sylvester's plaid of order eight, or four, or two: row r has a
  /// dark square in column c when r and c share an odd number of set
  /// bits.
  static List<int> sylvester(int size) => [
        for (var r = 0; r < size; r++)
          [for (var c = 0; c < size; c++) if (_bits(r & c).isOdd) 1 << c].fold(0, (a, b) => a | b),
      ];

  static int _bits(int x) {
    var n = 0;
    while (x > 0) {
      n += x & 1;
      x >>= 1;
    }
    return n;
  }
}
