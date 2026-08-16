import 'frac.dart';

/// A peg or a point of the field: whole coordinates.
typedef Peg = (int, int);

/// An exact point.
typedef Point = (Frac, Frac);

/// A circle of radius five about the middle of a field of pegs, twelve
/// pegs on its rim, and a triangle with its corners on the rim. From
/// any point drop a foot onto each of the three side-lines: the three
/// feet lie in a line exactly when the point is on the rim, as Wallace
/// found in 1799 and Simson is credited with, and more, the triangle
/// of the feet is to the big triangle as the square of the radius less
/// the square of the point's distance from the middle is to four times
/// the square of the radius, Euler's rule of 1763, nought on the rim.
class Rules {
  static const radius = 5, reach = 5;

  static const radiusSquared = radius * radius;

  /// The twelve pegs on the rim, round from (5, 0).
  static const rim = <Peg>[(5, 0), (4, 3), (3, 4), (0, 5), (-3, 4), (-4, 3), (-5, 0), (-4, -3), (-3, -4), (0, -5), (3, -4), (4, -3)];

  /// Every point of the field, whole coordinates from -5 to 5.
  static final field = <Peg>[
    for (var y = -reach; y <= reach; y++)
      for (var x = -reach; x <= reach; x++) (x, y),
  ];

  static bool onRim(Peg p) => p.$1 * p.$1 + p.$2 * p.$2 == radiusSquared;

  static bool inField(Peg p) => p.$1.abs() <= reach && p.$2.abs() <= reach;

  static int distanceSquared(Peg p) => p.$1 * p.$1 + p.$2 * p.$2;

  /// Every triangle of three rim pegs, in rim order.
  static List<List<Peg>> get triangles => [
        for (var i = 0; i < rim.length; i++)
          for (var j = i + 1; j < rim.length; j++)
            for (var k = j + 1; k < rim.length; k++) [rim[i], rim[j], rim[k]],
      ];

  /// The foot of the perpendicular from [p] onto the line through [a]
  /// and [b].
  static Point foot(Peg p, Peg a, Peg b) {
    final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
    final t = Frac.of((p.$1 - a.$1) * dx + (p.$2 - a.$2) * dy, dx * dx + dy * dy);
    return (Frac.of(a.$1) + t * Frac.of(dx), Frac.of(a.$2) + t * Frac.of(dy));
  }

  /// The three feet of [p] on the sides BC, CA and AB of the triangle.
  static List<Point> feet(List<Peg> t, Peg p) => [foot(p, t[1], t[2]), foot(p, t[2], t[0]), foot(p, t[0], t[1])];

  /// Whether three exact points lie in a line.
  static bool inLine(Point a, Point b, Point c) => (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1) == Frac.zero;

  /// The signed area of the triangle of three exact points, twice, by
  /// the shoelace.
  static Frac twiceArea(Point a, Point b, Point c) => (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);

  static Frac twiceAreaOf(List<Peg> t) => twiceArea(_pt(t[0]), _pt(t[1]), _pt(t[2]));

  static Point _pt(Peg p) => (Frac.of(p.$1), Frac.of(p.$2));

  /// The feet's triangle against the whole, by the feet themselves: the
  /// first voice.
  static Frac ratioByFeet(List<Peg> t, Peg p) {
    final f = feet(t, p);
    return twiceArea(f[0], f[1], f[2]) / twiceAreaOf(t);
  }

  /// The feet's triangle against the whole by Euler's rule, no foot in
  /// sight: the second voice.
  static Frac ratioByEuler(Peg p) => Frac.of(radiusSquared - distanceSquared(p), 4 * radiusSquared);

  /// The line the feet lie on when they do, as two of them, or null.
  static (Point, Point)? simsonLine(List<Peg> t, Peg p) {
    final f = feet(t, p);
    if (!inLine(f[0], f[1], f[2])) return null;
    // Two feet apart, if any two are.
    if (f[0] != f[1]) return (f[0], f[1]);
    if (f[0] != f[2]) return (f[0], f[2]);
    return null;
  }

  static bool through((Point, Point) line, Point q) => inLine(line.$1, line.$2, q);

  static bool level((Point, Point) line) => line.$1.$2 == line.$2.$2;

  static bool alongSide((Point, Point) line, List<Peg> t) {
    final (u, v) = line;
    final dx = v.$1 - u.$1, dy = v.$2 - u.$2;
    for (var i = 0; i < 3; i++) {
      final a = t[i], b = t[(i + 1) % 3];
      if (dx * Frac.of(b.$2 - a.$2) - dy * Frac.of(b.$1 - a.$1) == Frac.zero) return true;
    }
    return false;
  }

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';

  static String tellPoint(Point p) => '(${p.$1}, ${p.$2})';
}
