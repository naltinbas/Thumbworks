import 'dart:math';

/// The arithmetic of the ladder: a side and a diagonal, whole numbers
/// both, and how far the diagonal squared is from twice the side
/// squared. Two voices: the sweep, every side and diagonal to the top of
/// the dials tried with whole numbers; and the ladder, the Greek rule
/// that climbs from a side and diagonal to the next by adding, side plus
/// diagonal and twice the side plus the diagonal, and misses a true
/// diagonal by one either way at every rung.
class Rules {
  /// The dials run from one to this.
  static const most = 120;

  /// How many settings the two dials have between them.
  static const settings = most * most;

  /// The diagonal squared less twice the side squared: nought for a true
  /// diagonal, which never comes.
  static int miss(int side, int diagonal) => diagonal * diagonal - 2 * side * side;

  /// The next rung of the ladder from a side and diagonal.
  static (int, int) climb(int side, int diagonal) => (side + diagonal, 2 * side + diagonal);

  /// The rungs of the ladder from (1, 1) up to the top of the dials.
  static List<(int, int)> get rungs {
    final out = <(int, int)>[(1, 1)];
    while (true) {
      final (s, d) = climb(out.last.$1, out.last.$2);
      if (s > most || d > most) return out;
      out.add((s, d));
    }
  }

  /// How far the diagonal over the side is from the true diagonal, the
  /// square root of two, in doubles: no whole ratio can tie it, the root
  /// being irrational.
  static double off(int side, int diagonal) => (diagonal / side - sqrt2).abs();

  /// How far the diagonal is from side times the root of two, the
  /// measure the records are kept in.
  static double slack(int side, int diagonal) => (diagonal - side * sqrt2).abs();

  /// The nearest whole diagonal to a side's true one.
  static int nearest(int side) => (side * sqrt2).round();

  /// Whether the pair is a record: the diagonal is the nearest for its
  /// side, and it comes nearer the true diagonal, by [slack], than any
  /// pair with a smaller side.
  static bool isRecord(int side, int diagonal) {
    if (diagonal != nearest(side)) return false;
    final mine = slack(side, diagonal);
    for (var s = 1; s < side; s++) {
      if (slack(s, nearest(s)) <= mine) return false;
    }
    return true;
  }

  /// The records, side by side.
  static List<(int, int)> get records => [
        for (var s = 1; s <= most; s++)
          if (isRecord(s, nearest(s)) && nearest(s) <= most) (s, nearest(s)),
      ];

  /// Sweeps every setting of the two dials: how many meet [ask], how many
  /// there are, and the first that meets it, the side climbing slowest.
  static (int, int, (int, int)?) sweep(bool Function(int side, int diagonal) ask) {
    var met = 0, all = 0;
    (int, int)? first;
    for (var side = 1; side <= most; side++) {
      for (var diagonal = 1; diagonal <= most; diagonal++) {
        all++;
        if (ask(side, diagonal)) {
          met++;
          first ??= (side, diagonal);
        }
      }
    }
    return (met, all, first);
  }

  static String commas(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }
}
