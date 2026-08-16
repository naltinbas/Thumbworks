import 'frac.dart';

/// A peg on the wheel: whole coordinates on the circle of radius five.
typedef Peg = (int, int);

/// An exact point.
typedef Point = (Frac, Frac);

/// The wheel, its twelve pegs, the chords between them, and where two
/// chords cross: the pieces of each chord multiply to the same amount,
/// the radius squared less the crossing's distance from the middle
/// squared.
class Rules {
  static const radius = 5;

  /// The twelve pegs: every whole point on x squared + y squared = 25,
  /// clockwise from the top.
  static const pegs = <Peg>[
    (0, 5), (3, 4), (4, 3), (5, 0), (4, -3), (3, -4), (0, -5), (-3, -4), (-4, -3), (-5, 0), (-4, 3), (-3, 4),
  ];

  static bool onWheel(Peg p) => p.$1 * p.$1 + p.$2 * p.$2 == radius * radius;

  /// Every chord: a pair of pegs, the lower index first, 66 in all.
  static List<(int, int)> get chords => [for (var i = 0; i < pegs.length; i++) for (var j = i + 1; j < pegs.length; j++) (i, j)];

  static Point whole(Peg p) => (Frac.of(p.$1), Frac.of(p.$2));

  static int _cross(Peg a, Peg b, Peg c) => (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);

  /// Where chord ab meets chord cd strictly inside both, or null: they
  /// must not share a peg, and each must have the other's ends on
  /// opposite sides.
  static Point? crossing(Peg a, Peg b, Peg c, Peg d) {
    if (a == c || a == d || b == c || b == d) return null;
    final s1 = _cross(a, b, c), s2 = _cross(a, b, d), s3 = _cross(c, d, a), s4 = _cross(c, d, b);
    if (s1 == 0 || s2 == 0 || s3 == 0 || s4 == 0) return null;
    if ((s1 > 0) == (s2 > 0) || (s3 > 0) == (s4 > 0)) return null;
    // a + t (b - a) with t = s3 / (s3 - s4).
    final t = Frac.of(s3, s3 - s4);
    return (Frac.of(a.$1) + t * Frac.of(b.$1 - a.$1), Frac.of(a.$2) + t * Frac.of(b.$2 - a.$2));
  }

  /// The two pieces of chord ab about the crossing p, multiplied: since
  /// p lies between a and b, the lengths multiply to minus the dot of
  /// the two arms, exact and never a root. The first voice.
  static Frac product(Point p, Peg a, Peg b) {
    final ax = Frac.of(a.$1) - p.$1, ay = Frac.of(a.$2) - p.$2, bx = Frac.of(b.$1) - p.$1, by = Frac.of(b.$2) - p.$2;
    return Frac.zero - (ax * bx + ay * by);
  }

  /// The power of the crossing: the radius squared less its distance
  /// from the middle squared. The second voice, no chord read.
  static Frac power(Point p) => Frac.of(radius * radius) - (p.$1 * p.$1 + p.$2 * p.$2);

  /// A piece's length squared, exact.
  static Frac piece2(Point p, Peg a) => (Frac.of(a.$1) - p.$1) * (Frac.of(a.$1) - p.$1) + (Frac.of(a.$2) - p.$2) * (Frac.of(a.$2) - p.$2);

  /// Whether the two chords cross at right angles.
  static bool square(Peg a, Peg b, Peg c, Peg d) => (b.$1 - a.$1) * (d.$1 - c.$1) + (b.$2 - a.$2) * (d.$2 - c.$2) == 0;

  /// Whether the crossing is the middle of chord ab.
  static bool halves(Point p, Peg a, Peg b) => piece2(p, a) == piece2(p, b);

  static bool isMiddle(Point p) => p.$1 == Frac.zero && p.$2 == Frac.zero;

  static bool isDiameter(Peg a, Peg b) => a.$1 == -b.$1 && a.$2 == -b.$2;

  /// Every pair of chords that cross inside: (chord, chord) by index
  /// into [chords], the lower first.
  static List<((int, int), (int, int))> get crossings {
    final all = chords;
    final out = <((int, int), (int, int))>[];
    for (var i = 0; i < all.length; i++) {
      for (var j = i + 1; j < all.length; j++) {
        final (a, b) = all[i];
        final (c, d) = all[j];
        if (crossing(pegs[a], pegs[b], pegs[c], pegs[d]) != null) out.add((all[i], all[j]));
      }
    }
    return out;
  }

  /// A length squared told: '4' for a whole length, 'root 20' otherwise.
  static String tellLength(Frac l2) {
    if (l2.isWhole) {
      final n = l2.n.toInt();
      var k = 0;
      while (k * k < n) {
        k++;
      }
      if (k * k == n) return '$k';
    }
    return 'root $l2';
  }

  static String tellPoint(Point p) => '(${p.$1}, ${p.$2})';

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';
}
