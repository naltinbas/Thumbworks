/// The law of the table: a ball shot from the bottom left corner of a p
/// by q table at forty-five degrees runs one unit along and one up each
/// step, turns at a cushion, and stops in the first pocket it reaches.
/// Unfold the table across every cushion it meets and the path is the
/// straight diagonal, so it pockets at the first point (L, L) that is a
/// corner of the unfolded grid, L the least common multiple of p and q,
/// having crossed L/p tables along and L/q up. Which pocket is a matter
/// of parity: an odd count of tables along ends on the right, even on
/// the left, and the same up; and since L/p and L/q are p and q with
/// their common factor divided out, they are never both even, so the
/// ball never comes home to the corner it left. The bounces are
/// L/p - 1 + L/q - 1.
class Rules {
  /// The sides the sham allows.
  static const least = 2;
  static const most = 12;

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// The pocket by parity: (x, y) with x = p or 0 and y = q or 0.
  static (int, int) pocketByParity(int p, int q) {
    final g = gcd(p, q);
    final along = q ~/ g, up = p ~/ g;
    return (along.isOdd ? p : 0, up.isOdd ? q : 0);
  }

  /// The bounces by the formula: tables crossed along and up, less two.
  static int bouncesByFormula(int p, int q) {
    final g = gcd(p, q);
    return q ~/ g + p ~/ g - 2;
  }

  /// The steps to the pocket: the least common multiple.
  static int stepsByFormula(int p, int q) => p * q ~/ gcd(p, q);

  /// The ball rolled step by step: the path's corners as points from
  /// (0, 0) to the pocket, the bounces and the steps.
  static (List<(int, int)>, int, int) roll(int p, int q) {
    var x = 0, y = 0, dx = 1, dy = 1, steps = 0, bounces = 0;
    final corners = <(int, int)>[(0, 0)];
    while (true) {
      x += dx;
      y += dy;
      steps++;
      final atX = x == 0 || x == p, atY = y == 0 || y == q;
      if (atX && atY) {
        corners.add((x, y));
        return (corners, bounces, steps);
      }
      if (atX) {
        dx = -dx;
        bounces++;
        corners.add((x, y));
      }
      if (atY) {
        dy = -dy;
        bounces++;
        corners.add((x, y));
      }
      if (steps > 4 * p * q) throw StateError('the ball never pockets');
    }
  }

  /// Every table on the sham, asked, and how many meet the ask, with the
  /// count of tables.
  static (int, int) sweep(bool Function(int p, int q) ask) {
    var met = 0, all = 0;
    for (var p = least; p <= most; p++) {
      for (var q = least; q <= most; q++) {
        all++;
        if (ask(p, q)) met++;
      }
    }
    return (met, all);
  }

  /// The first table meeting [ask], sides along first, or null.
  static (int, int)? first(bool Function(int p, int q) ask) {
    for (var p = least; p <= most; p++) {
      for (var q = least; q <= most; q++) {
        if (ask(p, q)) return (p, q);
      }
    }
    return null;
  }

  /// A pocket's name.
  static String pocketName(int p, int q, (int, int) pocket) {
    if (pocket == (p, q)) return 'the far pocket';
    if (pocket == (p, 0)) return 'the right pocket';
    if (pocket == (0, q)) return 'the top pocket';
    return 'the home pocket';
  }
}
