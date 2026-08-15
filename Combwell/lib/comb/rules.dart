/// The law of the comb: nineteen cells in rows of three, four, five,
/// four and three, numbered row by row from the top left, and fifteen
/// lines through them, five each way, that are all to sum alike.
class Rules {
  const Rules(this.sum);

  /// What every line is to sum to.
  final int sum;

  static const cells = 19;

  /// The rows, top to bottom.
  static const rows = [
    [0, 1, 2],
    [3, 4, 5, 6],
    [7, 8, 9, 10, 11],
    [12, 13, 14, 15],
    [16, 17, 18],
  ];

  /// The lines slanting one way, and the other.
  static const slantsDown = [
    [0, 3, 7],
    [1, 4, 8, 12],
    [2, 5, 9, 13, 16],
    [6, 10, 14, 17],
    [11, 15, 18],
  ];

  static const slantsUp = [
    [2, 6, 11],
    [1, 5, 10, 15],
    [0, 4, 9, 14, 18],
    [3, 8, 13, 17],
    [7, 12, 16],
  ];

  static const lines = [...rows, ...slantsDown, ...slantsUp];

  /// The order the walk fills cells in when nothing forces them:
  /// chosen so that every free choice soon forces a cell.
  static const order = [0, 1, 3, 6, 4, 8, 9, 2, 5, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  /// The row and place of cell [c].
  static (int, int) placeOf(int c) {
    for (var r = 0; r < rows.length; r++) {
      final i = rows[r].indexOf(c);
      if (i >= 0) return (r, i);
    }
    throw ArgumentError('no cell $c');
  }

  /// The lines through cell [c].
  static List<int> linesOf(int c) => [
        for (var i = 0; i < lines.length; i++)
          if (lines[i].contains(c)) i,
      ];

  /// What line [i] comes to as [values] stand, and how many of its cells
  /// are empty: (sum, empty).
  (int, int) lineStanding(List<int> values, int i) {
    var s = 0, empty = 0;
    for (final c in lines[i]) {
      if (values[c] == 0) {
        empty++;
      } else {
        s += values[c];
      }
    }
    return (s, empty);
  }

  /// Whether the comb is full and every line sums to [sum].
  bool magic(List<int> values) {
    if (values.any((v) => v == 0)) return false;
    for (var i = 0; i < lines.length; i++) {
      if (lineStanding(values, i).$1 != sum) return false;
    }
    return true;
  }

  /// Every filling of the empty cells of [given] with the numbers left,
  /// nought for empty, that makes every line sum to [sum]: the walk
  /// fills the cells the order says, and whenever a line has one cell
  /// empty that cell is forced. Returns the fillings found, up to
  /// [most] of them.
  List<List<int>> fillings(List<int> given, {int most = 1000}) {
    final val = List<int>.of(given);
    final used = List<bool>.filled(cells + 1, false);
    for (final v in given) {
      if (v != 0) used[v] = true;
    }
    final found = <List<int>>[];

    List<int>? propagate() {
      final forced = <int>[];
      var changed = true;
      while (changed) {
        changed = false;
        for (final l in lines) {
          var s = 0, empty = 0, emptyCell = -1;
          for (final c in l) {
            if (val[c] != 0) {
              s += val[c];
            } else {
              empty++;
              emptyCell = c;
            }
          }
          if (empty == 0) {
            if (s != sum) {
              for (final c in forced) {
                used[val[c]] = false;
                val[c] = 0;
              }
              return null;
            }
            continue;
          }
          if (empty == 1) {
            final need = sum - s;
            if (need < 1 || need > cells || used[need]) {
              for (final c in forced) {
                used[val[c]] = false;
                val[c] = 0;
              }
              return null;
            }
            val[emptyCell] = need;
            used[need] = true;
            forced.add(emptyCell);
            changed = true;
          }
        }
      }
      return forced;
    }

    void go() {
      if (found.length >= most) return;
      final forced = propagate();
      if (forced == null) return;
      int? cell;
      for (final c in order) {
        if (val[c] == 0) {
          cell = c;
          break;
        }
      }
      if (cell == null) {
        found.add(List.of(val));
      } else {
        for (var v = 1; v <= cells; v++) {
          if (used[v]) continue;
          val[cell] = v;
          used[v] = true;
          go();
          val[cell] = 0;
          used[v] = false;
          if (found.length >= most) break;
        }
      }
      for (final c in forced) {
        used[val[c]] = false;
        val[c] = 0;
      }
    }

    go();
    return found;
  }

  /// The twelve turnings and reflections of the comb, each as the cell
  /// each cell goes to.
  static List<List<int>> get symmetries {
    // Cube coordinates for each cell: (q, r, s), q + r + s = 0.
    final cube = <(int, int, int)>[];
    for (var r = -2; r <= 2; r++) {
      final qs = <int>[];
      for (var q = -2; q <= 2; q++) {
        if ((-q - r).abs() <= 2) qs.add(q);
      }
      for (final q in qs) {
        cube.add((q, r, -q - r));
      }
    }
    int cellOf((int, int, int) p) => cube.indexOf(p);
    (int, int, int) turn((int, int, int) p) => (-p.$3, -p.$1, -p.$2);
    (int, int, int) mirror((int, int, int) p) => (p.$3, p.$2, p.$1);
    final out = <List<int>>[];
    for (final flip in [false, true]) {
      var pts = [for (final p in cube) flip ? mirror(p) : p];
      for (var t = 0; t < 6; t++) {
        out.add([for (final p in pts) cellOf(p)]);
        pts = [for (final p in pts) turn(p)];
      }
    }
    return out;
  }

  /// [values] carried by a symmetry: cell c's number goes to cell to[c].
  static List<int> carry(List<int> values, List<int> to) {
    final out = List<int>.filled(cells, 0);
    for (var c = 0; c < cells; c++) {
      out[to[c]] = values[c];
    }
    return out;
  }
}
