/// The arithmetic of the kite: the Aztec diamond of order n, the cells
/// (x, y) of the plane with |x + 1/2| + |y + 1/2| at most n, slated with
/// two-cell slates. Two voices: the sweep, every slating laid out from
/// the first bare cell on; and the formula, two to the n(n+1)/2.
class Kite {
  Kite(this.order) {
    for (var y = -order; y < order; y++) {
      for (var x = -order; x < order; x++) {
        if ((x + 0.5).abs() + (y + 0.5).abs() <= order) cells.add((x, y));
      }
    }
    for (var i = 0; i < cells.length; i++) {
      index[cells[i]] = i;
    }
  }

  final int order;

  /// The cells, rows from the top, left to right, as (x, y).
  final cells = <(int, int)>[];
  final index = <(int, int), int>{};

  int get count => cells.length;

  /// The rows the kite has, and the cells of row [y].
  List<int> get rows => [for (var y = -order; y < order; y++) y];

  /// The cell to the right of [i], or null.
  int? right(int i) => index[(cells[i].$1 + 1, cells[i].$2)];

  /// The cell below [i], or null.
  int? below(int i) => index[(cells[i].$1, cells[i].$2 + 1)];

  /// Whether cells [a] and [b] lie side by side.
  bool beside(int a, int b) {
    final (ax, ay) = cells[a];
    final (bx, by) = cells[b];
    return (ax - bx).abs() + (ay - by).abs() == 1;
  }

  /// Whether a slate over cells [a] and [b] lies across, not down.
  bool across(int a, int b) => cells[a].$2 == cells[b].$2;

  /// Every slating, each a list of slates (low cell, high cell) in the
  /// order the sweep lays them, from the first bare cell on: the first
  /// bare cell mates rightward or downward, and nothing else.
  List<List<(int, int)>> slatings() {
    final out = <List<(int, int)>>[];
    final covered = List.filled(count, false);
    final laid = <(int, int)>[];
    void go(int from) {
      var i = from;
      while (i < count && covered[i]) {
        i++;
      }
      if (i == count) {
        out.add(List.of(laid));
        return;
      }
      for (final mate in [right(i), below(i)]) {
        if (mate == null || covered[mate]) continue;
        covered[i] = true;
        covered[mate] = true;
        laid.add((i, mate));
        go(i + 1);
        laid.removeLast();
        covered[i] = false;
        covered[mate] = false;
      }
    }

    go(0);
    return out;
  }

  /// How many slatings, counted the same way without keeping them.
  int countSlatings() {
    final covered = List.filled(count, false);
    var n = 0;
    void go(int from) {
      var i = from;
      while (i < count && covered[i]) {
        i++;
      }
      if (i == count) {
        n++;
        return;
      }
      for (final mate in [right(i), below(i)]) {
        if (mate == null || covered[mate]) continue;
        covered[i] = true;
        covered[mate] = true;
        go(i + 1);
        covered[i] = false;
        covered[mate] = false;
      }
    }

    go(0);
    return n;
  }

  /// The formula: two to the n(n+1)/2.
  static int byFormula(int order) => 1 << (order * (order + 1) ~/ 2);

  /// How many slates of a slating lie across.
  int acrossCount(List<(int, int)> slating) => slating.where((s) => across(s.$1, s.$2)).length;

  /// Whether the slates given cover the kite exactly, none overlapping,
  /// each over two neighbours.
  bool covers(List<(int, int)> slates) {
    if (slates.length * 2 != count) return false;
    final seen = <int>{};
    for (final (a, b) in slates) {
      if (!beside(a, b) || !seen.add(a) || !seen.add(b)) return false;
    }
    return true;
  }
}
