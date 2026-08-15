/// A spot on the table: (x, y) in slanted coordinates, y the row from
/// the top and x the place along it, so that the spot sits on screen at
/// (x - y / 2, y) times the spacing and the rows nest as a triangular
/// lattice. The upright triangle of n rows is the spots with 0 <= x <=
/// y < n; a turned triangle with its point at (a, b) is the spots with
/// b - n < y <= b and a - (b - y) <= x <= a.
typedef Spot = (int, int);

/// The law of the pennies.
class Rules {
  const Rules(this.rows);

  /// Rows in the triangle.
  final int rows;

  /// Pennies in it.
  int get coins => rows * (rows + 1) ~/ 2;

  /// The upright triangle, top row first.
  List<Spot> get upright => [
        for (var y = 0; y < rows; y++)
          for (var x = 0; x <= y; x++) (x, y),
      ];

  /// The turned triangle with its point at [apex], point row first.
  List<Spot> turned(Spot apex) {
    final (a, b) = apex;
    return [
      for (var i = 0; i < rows; i++)
        for (var x = a - i; x <= a; x++) (x, b - i),
    ];
  }

  /// The point of the turned triangle the pennies as they lie make,
  /// anywhere, or null when they make none.
  Spot? pointOf(Set<Spot> lying) {
    if (lying.length != coins) return null;
    var lowest = lying.first.$2;
    for (final (_, y) in lying) {
      if (y > lowest) lowest = y;
    }
    final points = lying.where((s) => s.$2 == lowest).toList();
    if (points.length != 1) return null;
    return turned(points.single).every(lying.contains) ? points.single : null;
  }

  /// Whether the pennies as they lie are a turned triangle, anywhere.
  bool isTurned(Set<Spot> lying) => pointOf(lying) != null;

  /// How many of the pennies as they lie the turned triangle at [apex]
  /// would take in.
  int shared(Set<Spot> lying, Spot apex) => turned(apex).where(lying.contains).length;

  /// Every point whose turned triangle takes in at least one penny of the
  /// upright: the placements.
  List<Spot> get placements {
    final lying = upright.toSet();
    return [
      for (var b = -rows; b <= 3 * rows; b++)
        for (var a = -2 * rows; a <= 3 * rows; a++)
          if (shared(lying, (a, b)) > 0) (a, b),
    ];
  }

  /// The most pennies any placement takes in as they lie, by the sweep.
  int get bestShare {
    final lying = upright.toSet();
    var best = 0;
    for (final apex in placements) {
      final s = shared(lying, apex);
      if (s > best) best = s;
    }
    return best;
  }

  /// The fewest moves that turn the triangle, by the sweep: every penny
  /// the best placement leaves out must move, and one move each suffices.
  int get fewest => coins - bestShare;

  /// Placements within [moves] moves: those taking in at least coins
  /// less moves pennies as they lie.
  List<Spot> within(int moves) {
    final lying = upright.toSet();
    return [for (final apex in placements) if (shared(lying, apex) >= coins - moves) apex];
  }

  /// The rows' bound, no sweep: however the turned triangle lies, each of
  /// its rows shares at most the shorter of its length and the coin
  /// row's beneath it, so the most it can take in is the best over the
  /// row it points at of the sum of those.
  int get rowsBound {
    var best = 0;
    for (var b = 0; b <= 2 * rows - 2; b++) {
      var sum = 0;
      for (var i = 0; i < rows; i++) {
        final y = b - i;
        if (y < 0 || y >= rows) continue;
        final coinRow = y + 1, turnedRow = i + 1;
        sum += coinRow < turnedRow ? coinRow : turnedRow;
      }
      if (sum > best) best = sum;
    }
    return best;
  }

  /// A third of the pennies, rounded down: the fewest moves the sweep
  /// and the rows' bound both come to.
  int get third => coins ~/ 3;

  /// The spots the table shows: a row above the triangle and two below,
  /// each row a spot wider than the triangle at either end.
  List<Spot> get table => [
        for (var y = -1; y <= rows + 1; y++)
          for (var x = -1; x <= y + 1; x++) (x, y),
      ];

  /// The point of the turned triangle the pointer aims at: of the
  /// placements within the fewest moves, the one lowest and nearest the
  /// middle, which is the classic answer of the corners moving.
  Spot get aim {
    final best = within(fewest);
    Spot? pick;
    for (final apex in best) {
      if (pick == null || apex.$2 > pick.$2 || (apex.$2 == pick.$2 && (2 * apex.$1 - apex.$2).abs() < (2 * pick.$1 - pick.$2).abs())) {
        pick = apex;
      }
    }
    return pick!;
  }

  /// Every sequence of exactly [moves] moves on the table, a penny to an
  /// empty spot each, counted with those that end on a turned triangle:
  /// (landing, all).
  (int, int) sequences(int moves) {
    final spots = table;
    final lying = upright.toSet();
    var landing = 0, all = 0;
    void go(int left) {
      if (left == 0) {
        all++;
        if (isTurned(lying)) landing++;
        return;
      }
      for (final coin in lying.toList()) {
        lying.remove(coin);
        for (final spot in spots) {
          if (spot == coin || lying.contains(spot)) continue;
          lying.add(spot);
          go(left - 1);
          lying.remove(spot);
        }
        lying.add(coin);
      }
    }

    go(moves);
    return (landing, all);
  }
}
