import 'frac.dart';

/// A peg of the field: whole coordinates, x across and y up.
typedef Peg = (int, int);

/// An exact point.
typedef Point = (Frac, Frac);

/// The triangle A (0, 0), B (12, 0), C (0, 12) on a field of pegs, and
/// a line through two pegs cutting its three side-lines: where, in what
/// ratios, and how many sides inside.
class Rules {
  /// The field is [side] pegs by [side], 0 to side - 1 each way, and
  /// the triangle's legs are [leg] long.
  static const side = 13, leg = 12;

  static const Peg a = (0, 0), b = (12, 0), c = (0, 12);

  /// Twice the signed area of a, b, c.
  static int cross(Peg p, Peg q, Peg r) => (q.$1 - p.$1) * (r.$2 - p.$2) - (q.$2 - p.$2) * (r.$1 - p.$1);

  /// Whether the line through p and q cuts all three side-lines at
  /// points, none of them a corner: not parallel to a side and not
  /// through a corner.
  static bool crossesAll(Peg p, Peg q) {
    if (p == q) return false;
    final dx = q.$1 - p.$1, dy = q.$2 - p.$2;
    if (dy == 0 || dx == 0 || dx + dy == 0) return false;
    if (cross(p, q, a) == 0 || cross(p, q, b) == 0 || cross(p, q, c) == 0) return false;
    return true;
  }

  /// Where the line through p and q meets the line through u and v.
  static Point meet(Peg p, Peg q, Peg u, Peg v) {
    final s1 = cross(u, v, p), s2 = cross(u, v, q);
    // p + t (q - p) with t = s1 / (s1 - s2).
    final t = Frac.of(s1, s1 - s2);
    return (Frac.of(p.$1) + t * Frac.of(q.$1 - p.$1), Frac.of(p.$2) + t * Frac.of(q.$2 - p.$2));
  }

  /// The three crossings: F on AB, D on BC, E on CA.
  static (Point, Point, Point) crossings(Peg p, Peg q) => (meet(p, q, a, b), meet(p, q, b, c), meet(p, q, c, a));

  /// The signed ratios AF : FB, BD : DC and CE : EA, read off the
  /// crossings: each the crossing's distance from the side's first end
  /// over its distance to the second, along the side, negative when the
  /// crossing lies outside the side. The first voice.
  static (Frac, Frac, Frac) ratiosByCrossings(Peg p, Peg q) {
    final (f, d, e) = crossings(p, q);
    // F on AB: AF = f.x, FB = 12 - f.x. D on BC: BD runs by y, from 0 at
    // B to 12 at C, so BD = d.y, DC = 12 - d.y. E on CA: CE = 12 - e.y,
    // EA = e.y.
    final twelve = Frac.of(leg);
    return (f.$1 / (twelve - f.$1), d.$2 / (twelve - d.$2), (twelve - e.$2) / e.$2);
  }

  /// The same ratios by signed areas: the line divides a side in the
  /// ratio of the ends' distances from it, and the distance of a point
  /// from the line is its cross with p and q, so AF : FB is minus
  /// cross(A) over cross(B), and so on round. The second voice.
  static (Frac, Frac, Frac) ratiosByAreas(Peg p, Peg q) {
    final ca = cross(p, q, a), cb = cross(p, q, b), cc = cross(p, q, c);
    return (Frac.zero - Frac.of(ca, cb), Frac.zero - Frac.of(cb, cc), Frac.zero - Frac.of(cc, ca));
  }

  /// The product of the three signed ratios.
  static Frac product((Frac, Frac, Frac) r) => r.$1 * r.$2 * r.$3;

  /// Whether a crossing lies inside its side, strictly between the ends:
  /// a positive ratio.
  static bool inside(Frac ratio) => ratio.compareTo(Frac.zero) > 0;

  /// How many sides the line cuts inside.
  static int sidesInside(Peg p, Peg q) {
    final (x, y, z) = ratiosByCrossings(p, q);
    return (inside(x) ? 1 : 0) + (inside(y) ? 1 : 0) + (inside(z) ? 1 : 0);
  }

  /// The line's name: a x + b y = c in lowest terms with a > 0, or a = 0
  /// and b > 0.
  static (int, int, int) lineOf(Peg p, Peg q) {
    var la = q.$2 - p.$2, lb = p.$1 - q.$1;
    var lc = la * p.$1 + lb * p.$2;
    final g = _gcd(_gcd(la.abs(), lb.abs()), lc.abs());
    la ~/= g;
    lb ~/= g;
    lc ~/= g;
    if (la < 0 || (la == 0 && lb < 0)) {
      la = -la;
      lb = -lb;
      lc = -lc;
    }
    return (la, lb, lc);
  }

  static int _gcd(int x, int y) => y == 0 ? x : _gcd(y, x % y);

  /// Every peg of the field.
  static List<Peg> get pegs => [for (var y = 0; y < side; y++) for (var x = 0; x < side; x++) (x, y)];

  /// Every line through two pegs of the field that crosses all three
  /// side-lines, each once, as a pair of pegs on it: the first pair the
  /// sweep meets.
  static List<(Peg, Peg)> get lines {
    final seen = <(int, int, int)>{};
    final out = <(Peg, Peg)>[];
    final all = pegs;
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        final p = all[i], q = all[j];
        if (!crossesAll(p, q)) continue;
        if (seen.add(lineOf(p, q))) out.add((p, q));
      }
    }
    return out;
  }

  static String tell(Frac f) => '$f';

  static String tellPoint(Point p) => '(${p.$1}, ${p.$2})';

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';
}
