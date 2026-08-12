/// The law of the stream.
///
/// A ford is a fraction in lowest terms: how far across the stream
/// it sits, and its depth is its denominator. Two banks a/b and c/d
/// are neighbours when bc - ad = 1, and the wader's next stone is
/// always their mediant, (a+c)/(b+d), which splits the reach in two.
///
/// What holds it all together is known two ways that share nothing.
/// The crossing number bc - ad stays exactly one down every wade, an
/// invariant three lines long, and one is also exactly when two
/// fords' circles kiss; and the sweep tries every ford of every
/// depth and finds none between two neighbouring banks shallower
/// than their mediant. The suite proves each against the other.
class Rules {
  /// The crossing number of two banks: bc - ad.
  static int crossing(int a, int b, int c, int d) => b * c - a * d;

  /// The mediant stone between two banks.
  static (int, int) mediant(int a, int b, int c, int d) =>
      (a + c, b + d);

  /// Whether the circles of two fords kiss: their distance equals
  /// the sum of their radii, worked in whole numbers. A ford p/q
  /// carries a circle of radius 1 over 2q squared, resting on the
  /// stream.
  static bool circlesKiss(int p, int q, int r, int s) {
    // distance^2 - (radius sum)^2 == 0, all over a common ground:
    // (ps - rq)^2 == 1 after the algebra, but worked longhand here
    // so this voice never leans on the crossing number.
    final dx = p * s - r * q; // times qs
    // (dx/(qs))^2 + ((s^2-q^2)/(2q^2s^2))^2 == ((s^2+q^2)/(2q^2s^2))^2
    // multiply through by (2q^2s^2)^2:
    final left = 4 * q * q * s * s * dx * dx +
        (s * s - q * q) * (s * s - q * q);
    final right = (s * s + q * q) * (s * s + q * q);
    return left == right;
  }

  /// The fords of the stream to a depth: every fraction in lowest
  /// terms with denominator up to [deep], 0/1 to 1/1.
  static List<(int, int)> fords(int deep) => [
        for (var q = 1; q <= deep; q++)
          for (var p = 0; p <= q; p++)
            if (_gcd(p, q) == 1) (p, q),
      ];

  /// The shallowest fords strictly between two banks, swept depth by
  /// depth; empty when none exist to [deep].
  static List<(int, int)> shallowestBetween(
      int a, int b, int c, int d, int deep) {
    for (var q = 1; q <= deep; q++) {
      final found = <(int, int)>[];
      for (var p = 0; p <= q; p++) {
        if (_gcd(p, q) != 1) continue;
        // a/b < p/q < c/d, in whole numbers.
        if (p * b > a * q && c * q > p * d) found.add((p, q));
      }
      if (found.isNotEmpty) return found;
    }
    return const [];
  }

  /// The wades from the whole stream's banks to a ford, counting
  /// each mediant taken; -1 if the walk never lands (it always
  /// does, for a ford in lowest terms).
  static int wadesTo(int tp, int tq) {
    var a = 0, b = 1, c = 1, d = 1;
    var steps = 0;
    while (steps < 64) {
      final (p, q) = mediant(a, b, c, d);
      steps++;
      if (p * tq == tp * q) return steps;
      if (tp * q < p * tq) {
        c = p;
        d = q;
      } else {
        a = p;
        b = q;
      }
    }
    return -1;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
