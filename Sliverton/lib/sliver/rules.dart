import 'frac.dart';

/// An exact point of the field.
typedef Spot = (Frac, Frac);

/// A triangle field with its corners at A (0, 0), B (12, 0) and C
/// (0, 12), each side marked off in twelfths. A cut runs from each
/// corner to a mark on the far side, and the three cuts leave a sliver
/// in the middle. Routh's rule, published in 1891, gives the sliver's
/// share of the field as (xyz - 1) squared over
/// (xy + x + 1)(yz + y + 1)(zx + z + 1), where x is BD over DC, y is CE
/// over EA and z is AF over FB; the sliver vanishes exactly when xyz is
/// one, which is when the three cuts meet at a point, as Ceva said in
/// 1678.
class Rules {
  static const side = 12;

  /// The corners.
  static const a = (0, 0), b = (side, 0), c = (0, side);

  /// The marks a cut may run to: a twelfth to eleven twelfths along.
  static const least = 1, most = side - 1;

  static bool valid(List<int> marks) => marks.length == 3 && marks.every((m) => m >= least && m <= most);

  /// Where the mark [d] twelfths along BC falls, B towards C.
  static Spot onBC(int d) => (Frac.of(side * (side - d), side), Frac.of(side * d, side));

  /// Where the mark [e] twelfths along CA falls, C towards A.
  static Spot onCA(int e) => (Frac.zero, Frac.of(side * (side - e), side));

  /// Where the mark [f] twelfths along AB falls, A towards B.
  static Spot onAB(int f) => (Frac.of(side * f, side), Frac.zero);

  static Spot spotOf((int, int) p) => (Frac.of(p.$1), Frac.of(p.$2));

  /// The ratio BD to DC, as a fraction: d twelfths along gives d over
  /// twelve less d.
  static Frac ratioX(int d) => Frac.of(d, side - d);

  /// The ratio CE to EA.
  static Frac ratioY(int e) => Frac.of(e, side - e);

  /// The ratio AF to FB.
  static Frac ratioZ(int f) => Frac.of(f, side - f);

  /// Where the line through [p] and [q] crosses the line through [r]
  /// and [s], or null when the two run parallel.
  static Spot? crossing(Spot p, Spot q, Spot r, Spot s) {
    final a1 = q.$2 - p.$2, b1 = p.$1 - q.$1;
    final c1 = a1 * p.$1 + b1 * p.$2;
    final a2 = s.$2 - r.$2, b2 = r.$1 - s.$1;
    final c2 = a2 * r.$1 + b2 * r.$2;
    final under = a1 * b2 - a2 * b1;
    if (under == Frac.zero) return null;
    return ((c1 * b2 - c2 * b1) / under, (a1 * c2 - a2 * c1) / under);
  }

  /// The three corners of the sliver: where the cuts cross each other.
  static List<Spot>? sliver(List<int> marks) {
    final ad = [spotOf(a), onBC(marks[0])];
    final be = [spotOf(b), onCA(marks[1])];
    final cf = [spotOf(c), onAB(marks[2])];
    final p = crossing(ad[0], ad[1], be[0], be[1]);
    final q = crossing(be[0], be[1], cf[0], cf[1]);
    final r = crossing(cf[0], cf[1], ad[0], ad[1]);
    if (p == null || q == null || r == null) return null;
    return [p, q, r];
  }

  /// Twice the area of a triangle of three exact points, signed.
  static Frac twiceArea(Spot p, Spot q, Spot r) =>
      (q.$1 - p.$1) * (r.$2 - p.$2) - (q.$2 - p.$2) * (r.$1 - p.$1);

  /// Twice the field's own area: 144.
  static Frac get twiceField => twiceArea(spotOf(a), spotOf(b), spotOf(c));

  /// The sliver's share of the field, by its corners: the first voice.
  static Frac shareByCorners(List<int> marks) {
    final s = sliver(marks);
    if (s == null) return Frac.zero;
    final twice = twiceArea(s[0], s[1], s[2]);
    final share = twice / twiceField;
    return share.n.isNegative ? Frac.zero - share : share;
  }

  /// The sliver's share by Routh's formula: the second voice.
  static Frac shareByRouth(List<int> marks) {
    final x = ratioX(marks[0]), y = ratioY(marks[1]), z = ratioZ(marks[2]);
    final top = x * y * z - Frac.one;
    final under = (x * y + x + Frac.one) * (y * z + y + Frac.one) * (z * x + z + Frac.one);
    return top * top / under;
  }

  /// Whether the three cuts meet at one point: Ceva's word, the product
  /// of the ratios one.
  static bool cutsMeet(List<int> marks) => ratioX(marks[0]) * ratioY(marks[1]) * ratioZ(marks[2]) == Frac.one;

  /// Whether the sliver's three corners fall together.
  static bool slivergone(List<int> marks) {
    final s = sliver(marks);
    return s == null || (s[0] == s[1] && s[1] == s[2]);
  }

  static String tellMarks(List<int> m) => '${m[0]}, ${m[1]} and ${m[2]} twelfths';

  static String tellSpot(Spot p) => '(${p.$1}, ${p.$2})';

  /// A share told: 'nothing', '1/7', '5/28'.
  static String tellShare(Frac f) => f == Frac.zero ? 'nothing' : '$f';
}
