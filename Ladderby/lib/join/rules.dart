import 'frac.dart';

/// A peg: which rail, 0 the bottom or 1 the top, and where along it.
typedef Peg = (int, int);

/// An exact point.
typedef Point = (Frac, Frac);

/// Two rails of pegs, three pegs picked on each, and the six cross-joins
/// between them: the joins that swap partners cross at three points,
/// and the three points lie on a line, as Pappus said.
class Rules {
  /// Pegs run 0 to [last] along each rail; the top rail is [height]
  /// above the bottom.
  static const last = 7, height = 6;

  static int get pegsPerRail => last + 1;

  /// Where a peg stands.
  static Point at(Peg p) => (Frac.of(p.$2), Frac.of(p.$1 == 0 ? 0 : height));

  /// Where the join from bottom peg [i] to top peg [j] crosses the join
  /// from bottom peg [k] to top peg [l], or null when the two run
  /// parallel. The first voice, by the general meeting of two lines.
  static Point? crossing(int i, int j, int k, int l) {
    final d1x = j - i, d2x = l - k;
    // Directions (d1x, h) and (d2x, h) are parallel when d1x == d2x.
    if (d1x == d2x) return null;
    // (i, 0) + t (d1x, h) = (k, 0) + s (d2x, h) gives t = s and
    // i + t d1x = k + t d2x, so t = (k - i) / (d1x - d2x).
    final t = Frac.of(k - i, d1x - d2x);
    return (Frac.of(i) + t * Frac.of(d1x), t * Frac.of(height));
  }

  /// The same crossing by the closed form for parallel rails: it stands
  /// at height h (k - i) / ((k - i) + (j - l)) and across at
  /// (j k - i l) / ((k - i) + (j - l)). The second voice.
  static Point? crossingByForm(int i, int j, int k, int l) {
    final den = (k - i) + (j - l);
    if (den == 0) return null;
    return (Frac.of(j * k - i * l, den), Frac.of(height * (k - i), den));
  }

  /// The three crossings of a hexagon: bottom pegs a, b, c and top pegs
  /// x, y, z give X = a-y with x-b, Y = a-z with x-c, Z = b-z with y-c;
  /// null when any pair runs parallel.
  static (Point, Point, Point)? crossings(List<int> bottom, List<int> top) {
    final x = crossing(bottom[0], top[1], bottom[1], top[0]);
    final y = crossing(bottom[0], top[2], bottom[2], top[0]);
    final z = crossing(bottom[1], top[2], bottom[2], top[1]);
    if (x == null || y == null || z == null) return null;
    return (x, y, z);
  }

  /// The three crossings by the closed form.
  static (Point, Point, Point)? crossingsByForm(List<int> bottom, List<int> top) {
    final x = crossingByForm(bottom[0], top[1], bottom[1], top[0]);
    final y = crossingByForm(bottom[0], top[2], bottom[2], top[0]);
    final z = crossingByForm(bottom[1], top[2], bottom[2], top[1]);
    if (x == null || y == null || z == null) return null;
    return (x, y, z);
  }

  /// Whether three exact points lie in a line.
  static bool inLine(Point p, Point q, Point r) =>
      (q.$1 - p.$1) * (r.$2 - p.$2) - (q.$2 - p.$2) * (r.$1 - p.$1) == Frac.zero;

  /// Every ordered pick of three different pegs on a rail.
  static List<List<int>> get triples => [
        for (var a = 0; a <= last; a++)
          for (var b = 0; b <= last; b++)
            for (var c = 0; c <= last; c++)
              if (a != b && b != c && a != c) [a, b, c],
      ];

  /// How many hexagons the rails hold: ordered triples on each.
  static int get hexagons => triples.length * triples.length;

  static String tell(Point p) => '(${p.$1}, ${p.$2})';
}
