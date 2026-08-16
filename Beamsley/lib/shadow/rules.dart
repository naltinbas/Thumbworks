import 'frac.dart';

/// A peg of the field: whole coordinates about the lantern.
typedef Peg = (int, int);

/// A point or a line in homogeneous whole numbers: (x, y, w) for the
/// point x/w, y/w, and w nought for a point at infinity; (a, b, c) for
/// the line ax + by + cw.
typedef Homo = (int, int, int);

/// A lantern at the middle of a field of pegs, a triangle of three pegs
/// about it, and its shadow triangle: each shadow peg lies along the ray
/// from the lantern through its peg, at a whole multiple of the
/// distance. Desargues showed in 1639 that where matching sides meet,
/// AB with A'B', BC with B'C' and CA with C'A', the three places lie on
/// one line, the axis, whatever the pegs and whatever the multiples.
class Rules {
  static const reach = 2;

  /// The multiples a shadow peg may sit at: never one, which would put
  /// the shadow on its peg, and never nought, the lantern itself.
  static const casts = [-2, -1, 2, 3];

  /// Every peg of the field but the lantern.
  static final pegs = <Peg>[
    for (var y = -reach; y <= reach; y++)
      for (var x = -reach; x <= reach; x++)
        if (x != 0 || y != 0) (x, y),
  ];

  static bool onField(Peg p) => p.$1.abs() <= reach && p.$2.abs() <= reach && (p.$1 != 0 || p.$2 != 0);

  /// The shadow of peg [p] cast [t] times out from the lantern.
  static Peg shadow(Peg p, int t) => (p.$1 * t, p.$2 * t);

  static Homo homo(Peg p) => (p.$1, p.$2, 1);

  /// The cross of two homogeneous triples: the line through two points,
  /// or the meeting of two lines.
  static Homo cross(Homo a, Homo b) => (
        a.$2 * b.$3 - a.$3 * b.$2,
        a.$3 * b.$1 - a.$1 * b.$3,
        a.$1 * b.$2 - a.$2 * b.$1,
      );

  /// A homogeneous triple in least terms, its first standing sign made
  /// positive, so that two names for one point come out alike.
  static Homo tidy(Homo h) {
    var g = _gcd(_gcd(h.$1.abs(), h.$2.abs()), h.$3.abs());
    if (g == 0) return h;
    var (x, y, w) = (h.$1 ~/ g, h.$2 ~/ g, h.$3 ~/ g);
    final lead = w != 0 ? w : (x != 0 ? x : y);
    if (lead < 0) {
      x = -x;
      y = -y;
      w = -w;
    }
    return (x, y, w);
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static bool isNowhere(Homo h) => h.$1 == 0 && h.$2 == 0 && h.$3 == 0;

  static bool atInfinity(Homo h) => h.$3 == 0 && !isNowhere(h);

  /// The determinant of three homogeneous triples: nought when they lie
  /// on one line.
  static int det(Homo a, Homo b, Homo c) =>
      a.$1 * (b.$2 * c.$3 - b.$3 * c.$2) - a.$2 * (b.$1 * c.$3 - b.$3 * c.$1) + a.$3 * (b.$1 * c.$2 - b.$2 * c.$1);

  /// The three meetings of matching sides, by homogeneous crosses: the
  /// first voice. AB with A'B', BC with B'C', CA with C'A'.
  static List<Homo> meetings(List<Peg> triangle, List<int> casts) {
    final out = <Homo>[];
    for (var i = 0; i < 3; i++) {
      final j = (i + 1) % 3;
      final p = homo(triangle[i]), q = homo(triangle[j]);
      final ps = homo(shadow(triangle[i], casts[i])), qs = homo(shadow(triangle[j], casts[j]));
      out.add(tidy(cross(cross(p, q), cross(ps, qs))));
    }
    return out;
  }

  /// Whether the three meetings lie on one line, by the determinant.
  static bool inLine(List<Homo> m) => det(m[0], m[1], m[2]) == 0;

  /// The axis, the line through the three meetings: the cross of two of
  /// them that are apart, or null when all three fall together.
  static Homo? axis(List<Homo> m) {
    for (var i = 0; i < 3; i++) {
      for (var j = i + 1; j < 3; j++) {
        final line = cross(m[i], m[j]);
        if (!isNowhere(line)) return tidy(line);
      }
    }
    return null;
  }

  /// The meetings again in plain fractions, the second voice: the two
  /// side-lines written as ax + by = c and solved, null where they run
  /// parallel or lie on one another.
  static (Frac, Frac)? meetingByHand(List<Peg> triangle, List<int> casts, int side) {
    final i = side, j = (side + 1) % 3;
    final a = triangle[i], b = triangle[j];
    final c = shadow(triangle[i], casts[i]), d = shadow(triangle[j], casts[j]);
    // The line through a and b: (b.y - a.y) x - (b.x - a.x) y = cross.
    final a1 = b.$2 - a.$2, b1 = -(b.$1 - a.$1), c1 = a1 * a.$1 + b1 * a.$2;
    final a2 = d.$2 - c.$2, b2 = -(d.$1 - c.$1), c2 = a2 * c.$1 + b2 * c.$2;
    final under = a1 * b2 - a2 * b1;
    if (under == 0) return null;
    return (Frac.of(c1 * b2 - c2 * b1, under), Frac.of(a1 * c2 - a2 * c1, under));
  }

  /// Whether the triangle's three pegs stand in a line.
  static bool flat(List<Peg> t) =>
      (t[1].$1 - t[0].$1) * (t[2].$2 - t[0].$2) - (t[1].$2 - t[0].$2) * (t[2].$1 - t[0].$1) == 0;

  /// Whether two of the pegs stand on one ray from the lantern: then
  /// that side and its shadow lie along the same line and have no one
  /// meeting, so the sweep leaves those triangles out.
  static bool sharesRay(List<Peg> t) {
    for (var i = 0; i < t.length; i++) {
      for (var j = i + 1; j < t.length; j++) {
        if (t[i].$1 * t[j].$2 - t[i].$2 * t[j].$1 == 0) return true;
      }
    }
    return false;
  }

  /// Whether the three pegs make a triangle the lantern can cast: three
  /// different pegs of the field, not in a line, no two on one ray.
  static bool valid(List<Peg> t) =>
      t.length == 3 && t.toSet().length == 3 && t.every(onField) && !flat(t) && !sharesRay(t);

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';

  /// A homogeneous point told: '(3, 1)' when it is somewhere, or 'the
  /// far point of 1 up 2 across' when it lies at infinity.
  static String tellPoint(Homo h) {
    if (isNowhere(h)) return 'nowhere';
    if (atInfinity(h)) return 'far off along ${h.$1}, ${h.$2}';
    final x = Frac.of(h.$1, h.$3), y = Frac.of(h.$2, h.$3);
    return '($x, $y)';
  }

  /// A line told: 'the line 2x + 3y = 4', or 'the line at infinity'.
  static String tellLine(Homo l) {
    if (l.$1 == 0 && l.$2 == 0) return 'the line at infinity';
    final left = <String>[];
    if (l.$1 != 0) left.add('${l.$1 == 1 ? '' : l.$1 == -1 ? '-' : '${l.$1} '}x');
    if (l.$2 != 0) left.add('${l.$2 == 1 ? '' : l.$2 == -1 ? '-' : '${l.$2} '}y');
    return 'the line ${left.join(' + ').replaceAll('+ -', '- ')} = ${-l.$3}';
  }
}
