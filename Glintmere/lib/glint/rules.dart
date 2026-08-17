/// A mirror laid along the bottom of the board, a lamp and an eye above
/// it, and the peg the light strikes on its way across.
///
/// Distances here are square roots, so nothing is ever worked out as a
/// number. A path is kept as the two squared legs and compared against
/// whatever it is being held to by squaring, which turns every question
/// into whole numbers. There is no decimal anywhere in this file.
class Rules {
  /// Pegs along the mirror, at 0 to 12.
  static const mirror = 13;

  /// How high the lamp and the eye may stand.
  static const sky = 5;

  /// The squared length of the leg from a point to a bounce on the
  /// mirror.
  static int leg(int x, int y, int bounce) =>
      (bounce - x) * (bounce - x) + y * y;

  /// The two squared legs of the path from the lamp to the eye by way of
  /// a bounce.
  static (int, int) legs(int lampX, int lampY, int eyeX, int eyeY, int bounce) =>
      (leg(lampX, lampY, bounce), leg(eyeX, eyeY, bounce));

  /// The squared straight run from the lamp to the eye folded across the
  /// mirror. Folding turns the bent path into a straight one, and no
  /// path beats a straight one, which is the whole of the theorem.
  static int folded(int lampX, int lampY, int eyeX, int eyeY) =>
      (eyeX - lampX) * (eyeX - lampX) +
      (lampY + eyeY) * (lampY + eyeY);

  /// Whether the root of [one] added to the root of [two] is at most
  /// [paces], settled in whole numbers.
  ///
  /// Squaring once gives one plus two plus twice the root of their
  /// product against paces squared, so what is left to compare is twice
  /// that root against a whole number, and squaring again finishes it.
  static bool within(int one, int two, int paces) {
    final over = paces * paces - one - two;
    if (over < 0) return false;
    return 4 * one * two <= over * over;
  }

  /// Whether the root of [one] added to the root of [two] is exactly the
  /// root of [whole].
  static bool equals(int one, int two, int whole) {
    final over = whole - one - two;
    if (over < 0) return false;
    return 4 * one * two == over * over;
  }

  /// The first voice on where the light really goes: the angle the light
  /// comes in at and the angle it leaves at, compared without ever
  /// working out an angle. The tangent of each is a run over a rise, so
  /// the two match exactly when the runs and rises cross-multiply, and
  /// the bounce has to lie between the lamp and the eye or the light
  /// never crosses the mirror at all.
  static bool anglesMatch(
      int lampX, int lampY, int eyeX, int eyeY, int bounce) {
    final low = lampX < eyeX ? lampX : eyeX;
    final high = lampX < eyeX ? eyeX : lampX;
    if (bounce < low || bounce > high) return false;
    return (bounce - lampX).abs() * eyeY == (eyeX - bounce).abs() * lampY;
  }

  /// The whole number of paces a path comes to, or null when it is not a
  /// whole number. A root added to a root is whole only when both roots
  /// are, so this asks whether each leg is a square.
  static int? paces(int one, int two) {
    final a = root(one), b = root(two);
    if (a == null || b == null) return null;
    return a + b;
  }

  /// The whole root of a number, or null when it has none.
  static int? root(int n) {
    if (n < 0) return null;
    var low = 0, high = n + 1;
    while (low + 1 < high) {
      final mid = (low + high) ~/ 2;
      if (mid * mid <= n) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low * low == n ? low : null;
  }

  /// Every peg of the mirror the light may be bounced off.
  static List<int> get bounces => [for (var p = 0; p < mirror; p++) p];
}
