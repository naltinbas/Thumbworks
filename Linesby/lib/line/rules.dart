import 'frac.dart';

/// A peg of the field: whole coordinates, x across and y up.
typedef Peg = (int, int);

/// A centre: exact coordinates.
typedef Centre = (Frac, Frac);

/// The field, the triangle on it, and its three centres: the centroid,
/// the circumcentre and the orthocentre, worked exactly.
class Rules {
  /// The field is [side] pegs by [side], 0 to side - 1 each way.
  static const side = 7;

  /// The nearest the field comes to an equilateral triangle: the sides
  /// squared 17, 17 and 18, the longest over the shortest. The checker
  /// sweeps every triangle to make sure nothing comes nearer.
  static const nearest = (18, 17);

  static final _third = Frac.of(1, 3), _two = Frac.of(2), _half = Frac.of(1, 2);

  static Centre whole(Peg p) => (Frac.of(p.$1), Frac.of(p.$2));

  /// Twice the signed area: nought when the pegs lie in a line.
  static int cross(Peg a, Peg b, Peg c) => (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);

  static bool inLine(Peg a, Peg b, Peg c) => cross(a, b, c) == 0;

  static int dot(Peg from, Peg p, Peg q) => (p.$1 - from.$1) * (q.$1 - from.$1) + (p.$2 - from.$2) * (q.$2 - from.$2);

  static int dist2(Peg p, Peg q) => (p.$1 - q.$1) * (p.$1 - q.$1) + (p.$2 - q.$2) * (p.$2 - q.$2);

  /// The sides squared, opposite a, b and c in turn.
  static List<int> sides(Peg a, Peg b, Peg c) => [dist2(b, c), dist2(c, a), dist2(a, b)];

  /// 'right', 'obtuse' or 'acute', by the dot products at the corners.
  static String kind(Peg a, Peg b, Peg c) {
    final dots = [dot(a, b, c), dot(b, c, a), dot(c, a, b)];
    if (dots.any((d) => d == 0)) return 'right';
    return dots.any((d) => d < 0) ? 'obtuse' : 'acute';
  }

  /// The corner the right angle stands at, or null.
  static Peg? rightAt(Peg a, Peg b, Peg c) => dot(a, b, c) == 0 ? a : dot(b, c, a) == 0 ? b : dot(c, a, b) == 0 ? c : null;

  static Centre centroid(Peg a, Peg b, Peg c) => (Frac.of(a.$1 + b.$1 + c.$1) * _third, Frac.of(a.$2 + b.$2 + c.$2) * _third);

  /// Solves p x + q y = r, s x + t y = u by Cramer's rule.
  static Centre _solve(int p, int q, int r, int s, int t, int u) {
    final det = p * t - q * s;
    return (Frac.of(r * t - q * u, det), Frac.of(p * u - r * s, det));
  }

  /// The circumcentre: the point as far from a as from b and from c,
  /// two linear equations from the equal distances squared.
  static Centre circumcentre(Peg a, Peg b, Peg c) {
    int sq(Peg p) => p.$1 * p.$1 + p.$2 * p.$2;
    return _solve(2 * (b.$1 - a.$1), 2 * (b.$2 - a.$2), sq(b) - sq(a), 2 * (c.$1 - a.$1), 2 * (c.$2 - a.$2), sq(c) - sq(a));
  }

  /// The orthocentre: where the altitude from a meets the altitude
  /// from b, each perpendicular to the side across.
  static Centre orthocentre(Peg a, Peg b, Peg c) => _solve(
        c.$1 - b.$1, c.$2 - b.$2, (c.$1 - b.$1) * a.$1 + (c.$2 - b.$2) * a.$2,
        c.$1 - a.$1, c.$2 - a.$2, (c.$1 - a.$1) * b.$1 + (c.$2 - a.$2) * b.$2,
      );

  /// The orthocentre by the second voice: a + b + c less twice the
  /// circumcentre, which is what the Euler line comes to.
  static Centre orthocentreByO(Peg a, Peg b, Peg c) {
    final o = circumcentre(a, b, c);
    return (Frac.of(a.$1 + b.$1 + c.$1) - _two * o.$1, Frac.of(a.$2 + b.$2 + c.$2) - _two * o.$2);
  }

  /// The nine-point centre, halfway from the circumcentre to the
  /// orthocentre.
  static Centre ninePoint(Peg a, Peg b, Peg c) {
    final o = circumcentre(a, b, c), h = orthocentre(a, b, c);
    return ((o.$1 + h.$1) * _half, (o.$2 + h.$2) * _half);
  }

  static Frac dist2F(Centre p, Centre q) => (p.$1 - q.$1) * (p.$1 - q.$1) + (p.$2 - q.$2) * (p.$2 - q.$2);

  /// Whether three exact points lie in a line.
  static bool inLineF(Centre p, Centre q, Centre r) =>
      (q.$1 - p.$1) * (r.$2 - p.$2) - (q.$2 - p.$2) * (r.$1 - p.$1) == Frac.zero;

  /// Whether the orthocentre stands twice as far from the centroid as
  /// the circumcentre does, on the far side: h - g = 2 (g - o).
  static bool twiceAsFar(Centre g, Centre o, Centre h) =>
      h.$1 - g.$1 == _two * (g.$1 - o.$1) && h.$2 - g.$2 == _two * (g.$2 - o.$2);

  /// Where the exact point stands to the triangle: 'inside', 'on the
  /// edge' or 'outside', by which way it turns from each side.
  static String where(Centre p, Peg a, Peg b, Peg c) {
    Frac turn(Peg u, Peg v) => (Frac.of(v.$1 - u.$1)) * (p.$2 - Frac.of(u.$2)) - (Frac.of(v.$2 - u.$2)) * (p.$1 - Frac.of(u.$1));
    final t = [turn(a, b), turn(b, c), turn(c, a)].map((x) => x.compareTo(Frac.zero)).toList();
    if (t.every((x) => x > 0) || t.every((x) => x < 0)) return 'inside';
    if (t.contains(0) && (t.every((x) => x >= 0) || t.every((x) => x <= 0))) return 'on the edge';
    return 'outside';
  }

  /// Whether the exact point lies on the field, edges included.
  static bool onField(Centre p) {
    final most = Frac.of(side - 1);
    return p.$1.compareTo(Frac.zero) >= 0 && p.$1.compareTo(most) <= 0 && p.$2.compareTo(Frac.zero) >= 0 && p.$2.compareTo(most) <= 0;
  }

  static bool isWhole(Centre p) => p.$1.isWhole && p.$2.isWhole;

  /// The longest side squared over the shortest, as (longest, shortest)
  /// in lowest terms: (1, 1) would be equilateral.
  static (int, int) spread(Peg a, Peg b, Peg c) {
    final s = sides(a, b, c);
    var lo = s.reduce((x, y) => x < y ? x : y), hi = s.reduce((x, y) => x > y ? x : y);
    final g = _gcd(hi, lo);
    return (hi ~/ g, lo ~/ g);
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Every peg of the field, row by row from the bottom left.
  static List<Peg> get pegs => [for (var y = 0; y < side; y++) for (var x = 0; x < side; x++) (x, y)];

  /// Every triangle of the field: three pegs not in a line, taken in
  /// the field's order once each.
  static List<(Peg, Peg, Peg)> get triangles {
    final all = pegs;
    final out = <(Peg, Peg, Peg)>[];
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        for (var k = j + 1; k < all.length; k++) {
          if (!inLine(all[i], all[j], all[k])) out.add((all[i], all[j], all[k]));
        }
      }
    }
    return out;
  }

  static String told(Centre p) => '(${p.$1}, ${p.$2})';

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';
}
