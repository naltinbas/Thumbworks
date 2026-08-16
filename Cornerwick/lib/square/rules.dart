import 'frac.dart';

/// A peg of the board, file then rank, 0 to 4.
typedef Peg = (int, int);

/// A point in doubled coordinates, so that the centres of the squares,
/// which sit at halves, stay whole.
typedef Point2 = (int, int);

/// Four pegs set in order, a square built outward on every side, and
/// the centres of the two squares on opposite sides joined: the two
/// joins are of one length and at right angles, whatever the four pegs.
/// Van Aubel proved it in 1878.
class Rules {
  static const side = 5;

  static final pegs = <Peg>[
    for (var y = 0; y < side; y++)
      for (var x = 0; x < side; x++) (x, y),
  ];

  static bool onBoard(Peg p) => p.$1 >= 0 && p.$1 < side && p.$2 >= 0 && p.$2 < side;

  /// The centre of the square built on the side from [p] to [q], to the
  /// right of the way from p to q, in doubled coordinates: the two ends
  /// added, and the way turned a right angle rightward.
  static Point2 centre(Peg p, Peg q) {
    final dx = q.$1 - p.$1, dy = q.$2 - p.$2;
    return (p.$1 + q.$1 + dy, p.$2 + q.$2 - dx);
  }

  /// The four corners of the square on the side from [p] to [q], to its
  /// right, in doubled coordinates.
  static List<Point2> square(Peg p, Peg q) {
    final dx = q.$1 - p.$1, dy = q.$2 - p.$2;
    return [(2 * p.$1, 2 * p.$2), (2 * q.$1, 2 * q.$2), (2 * q.$1 + 2 * dy, 2 * q.$2 - 2 * dx), (2 * p.$1 + 2 * dy, 2 * p.$2 - 2 * dx)];
  }

  /// The four centres of the squares on the four sides of the four pegs
  /// [f], in doubled coordinates: on AB, BC, CD and DA.
  static List<Point2> centres(List<Peg> f) => [for (var i = 0; i < 4; i++) centre(f[i], f[(i + 1) % 4])];

  /// The two joins as ways, from the AB centre to the CD centre and from
  /// the BC centre to the DA centre, doubled: the first voice reads
  /// their lengths and their angle off these.
  static (Point2, Point2) joins(List<Peg> f) {
    final c = centres(f);
    return ((c[2].$1 - c[0].$1, c[2].$2 - c[0].$2), (c[3].$1 - c[1].$1, c[3].$2 - c[1].$2));
  }

  /// The joins' lengths squared, in true units.
  static (Frac, Frac) lengthsSquared(List<Peg> f) {
    final (u, v) = joins(f);
    return (Frac.of(u.$1 * u.$1 + u.$2 * u.$2, 4), Frac.of(v.$1 * v.$1 + v.$2 * v.$2, 4));
  }

  static bool sameLength(List<Peg> f) {
    final (a, b) = lengthsSquared(f);
    return a == b;
  }

  static bool atRightAngles(List<Peg> f) {
    final (u, v) = joins(f);
    return u.$1 * v.$1 + u.$2 * v.$2 == 0;
  }

  /// The second voice: the first join turned a right angle leftward is
  /// the second join exactly, worked as one sum from the four pegs, with
  /// no centre and no length in it: r - p turned equals s - q.
  static bool turnedIsTheOther(List<Peg> f) {
    final a = f[0], b = f[1], c = f[2], d = f[3];
    // r - p, doubled: (c + d + turn(d - c)) - (a + b + turn(b - a)).
    final rp = (c.$1 + d.$1 + (d.$2 - c.$2) - a.$1 - b.$1 - (b.$2 - a.$2), c.$2 + d.$2 - (d.$1 - c.$1) - a.$2 - b.$2 + (b.$1 - a.$1));
    final sq = (d.$1 + a.$1 + (a.$2 - d.$2) - b.$1 - c.$1 - (c.$2 - b.$2), d.$2 + a.$2 - (a.$1 - d.$1) - b.$2 - c.$2 + (c.$1 - b.$1));
    // rp turned a right angle leftward, (-y, x), is sq.
    return (-rp.$2, rp.$1) == sq;
  }

  /// Where the two joins cross, in true units, or null when a join is a
  /// point.
  static (Frac, Frac)? crossing(List<Peg> f) {
    final c = centres(f);
    final (u, v) = joins(f);
    if (u == (0, 0) || v == (0, 0)) return null;
    // p + t u = q + s v; u and v are at right angles, so t = ((q - p) . u) / (u . u).
    final qp = (c[1].$1 - c[0].$1, c[1].$2 - c[0].$2);
    final t = Frac.of(qp.$1 * u.$1 + qp.$2 * u.$2, u.$1 * u.$1 + u.$2 * u.$2);
    final x = (Frac.of(c[0].$1) + t * Frac.of(u.$1)) / Frac.of(2);
    final y = (Frac.of(c[0].$2) + t * Frac.of(u.$2)) / Frac.of(2);
    return (x, y);
  }

  /// Whether the four centres make a square, corner by corner: four
  /// equal sides and two equal diagonals, none nought.
  static bool centresMakeSquare(List<Peg> f) {
    final c = centres(f);
    int d2(Point2 a, Point2 b) => (a.$1 - b.$1) * (a.$1 - b.$1) + (a.$2 - b.$2) * (a.$2 - b.$2);
    final s = [d2(c[0], c[1]), d2(c[1], c[2]), d2(c[2], c[3]), d2(c[3], c[0])];
    final g = [d2(c[0], c[2]), d2(c[1], c[3])];
    return s[0] > 0 && s.every((x) => x == s[0]) && g[0] == g[1] && g[0] == 2 * s[0];
  }

  /// Whether the four pegs are a parallelogram, first and third adding
  /// like second and fourth.
  static bool parallelogram(List<Peg> f) => f[0].$1 + f[2].$1 == f[1].$1 + f[3].$1 && f[0].$2 + f[2].$2 == f[1].$2 + f[3].$2;

  /// Whether every centre sits on a peg place, whole in true units.
  static bool centresWhole(List<Peg> f) => centres(f).every((c) => c.$1.isEven && c.$2.isEven);

  /// Every ordered four of different pegs, handed to [each]: 303,600.
  static void fours(void Function(List<Peg>) each) {
    for (final a in pegs) {
      for (final b in pegs) {
        if (b == a) continue;
        for (final c in pegs) {
          if (c == a || c == b) continue;
          for (final d in pegs) {
            if (d == a || d == b || d == c) continue;
            each([a, b, c, d]);
          }
        }
      }
    }
  }

  /// Whether three of the four pegs stand in a line.
  static bool threeInLine(List<Peg> f) {
    for (var i = 0; i < 4; i++) {
      for (var j = i + 1; j < 4; j++) {
        for (var k = j + 1; k < 4; k++) {
          final (a, b, c) = (f[i], f[j], f[k]);
          if ((b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1) == 0) return true;
        }
      }
    }
    return false;
  }

  static String tellPeg(Peg p) => '(${p.$1}, ${p.$2})';

  /// A length squared told as a length: '5' for 25, 'root 50' for 50.
  static String tellLength(Frac squared) {
    if (squared.isWhole) {
      final n = squared.n.toInt();
      var r = 0;
      while ((r + 1) * (r + 1) <= n) {
        r++;
      }
      if (r * r == n) return '$r';
      return 'root $n';
    }
    return 'root $squared';
  }
}
