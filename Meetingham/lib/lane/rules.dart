/// The arithmetic of the lanes: a field with corners A at the bottom
/// left, B at the bottom right and C at the top left, twelve paces a
/// side along the two straight sides, and a gate on each side, D on BC,
/// E on CA and F on AB, at whole paces from the corners. A lane runs
/// from each corner to the gate opposite. Two voices: the meeting, the
/// lanes from A and B crossed exactly in whole-number arithmetic and the
/// crossing tried on the lane from C; and Ceva's product, the three
/// side ratios multiplied coming to one exactly when the lanes meet.
class Rules {
  /// Paces along a side, and the gates: from one to one short of it.
  static const paces = 12;

  /// The corners, in lattice coordinates.
  static const (int, int) a = (0, 0), b = (paces, 0), c = (0, paces);

  /// Gate D on BC, [d] paces from B towards C; E on CA, [e] paces from C
  /// towards A; F on AB, [f] paces from A towards B.
  static (int, int) gateD(int d) => (paces - d, d);
  static (int, int) gateE(int e) => (0, paces - e);
  static (int, int) gateF(int f) => (f, 0);

  /// The crossing of the lane AD with the lane BE, as (numX, numY, den)
  /// whole numbers, the point being (numX/den, numY/den); den nought
  /// when the lanes are parallel, which they never are here.
  static (int, int, int) _crossing(int d, int e) {
    final gd = gateD(d), ge = gateE(e);
    final x1 = a.$1, y1 = a.$2, x2 = gd.$1, y2 = gd.$2;
    final x3 = b.$1, y3 = b.$2, x4 = ge.$1, y4 = ge.$2;
    final den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    final t1 = x1 * y2 - y1 * x2, t2 = x3 * y4 - y3 * x4;
    final numX = t1 * (x3 - x4) - (x1 - x2) * t2;
    final numY = t1 * (y3 - y4) - (y1 - y2) * t2;
    return (numX, numY, den);
  }

  /// Whether the three lanes meet at one point, by crossing: the lane AD
  /// and the lane BE meet at a point found as fractions, and the lane CF
  /// passes through it exactly when a cross product is nought.
  static bool meetByCrossing(int d, int e, int f) {
    final (numX, numY, den) = _crossing(d, e);
    if (den == 0) return false;
    final gf = gateF(f);
    final x5 = c.$1, y5 = c.$2, x6 = gf.$1, y6 = gf.$2;
    final cross = (x6 - x5) * (numY - y5 * den) - (y6 - y5) * (numX - x5 * den);
    return cross == 0;
  }

  /// Ceva's product as a fraction: (BD/DC)(CE/EA)(AF/FB), told as
  /// numerator and denominator in whole numbers.
  static (int, int) product(int d, int e, int f) => (d * e * f, (paces - d) * (paces - e) * (paces - f));

  /// Whether Ceva says the lanes meet: the product is one.
  static bool meetByCeva(int d, int e, int f) {
    final (n, den) = product(d, e, f);
    return n == den;
  }

  /// The meeting point of the lanes from A and B as fractions (x, y,
  /// den) in lowest terms, the denominator positive.
  static (int, int, int) meetingPoint(int d, int e, int f) {
    final (numX, numY, den) = _crossing(d, e);
    final g = _gcd(_gcd(numX.abs(), numY.abs()), den.abs());
    final s = den < 0 ? -1 : 1;
    return (s * numX ~/ g, s * numY ~/ g, s * den ~/ g);
  }

  static int _gcd(int x, int y) => y == 0 ? (x == 0 ? 1 : x) : _gcd(y, x % y);

  /// Every setting of the three gates: 11 by 11 by 11.
  static (int, int, int?) sweep(bool Function(int d, int e, int f) ask) {
    var met = 0, all = 0;
    (int, int, int)? first;
    for (var d = 1; d < paces; d++) {
      for (var e = 1; e < paces; e++) {
        for (var f = 1; f < paces; f++) {
          all++;
          if (ask(d, e, f)) {
            met++;
            first ??= (d, e, f);
          }
        }
      }
    }
    return (met, all, first == null ? null : first.$1 * 10000 + first.$2 * 100 + first.$3);
  }

  static int get settings => (paces - 1) * (paces - 1) * (paces - 1);

  /// A ratio told: 'BD:DC 1:2'.
  static String ratio(int at) {
    final g = _gcd(at, paces - at);
    return '${at ~/ g}:${(paces - at) ~/ g}';
  }
}
