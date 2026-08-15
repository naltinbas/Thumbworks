/// The law of the corner: a corner of a solid is a point where three or
/// more faces meet, and it closes only when the faces' angles at the
/// point come to less than a full turn, 360 degrees; at 360 exactly the
/// faces lie flat, and over it they overlap. A regular face of p sides
/// has corners of 180(p - 2)/p degrees, so q of them close a corner
/// exactly when (p - 2)(q - 2) < 4, which is five settings and no more.
///
/// Euler's count reads the same five another way: with F faces of p
/// sides, q meeting at each of V corners and E edges, pF = 2E = qV and
/// V - E + F = 2, so E = 2pq / (4 - (p - 2)(q - 2)), a whole positive
/// number for exactly the five.
///
/// Angles are kept as whole numbers of p-ths of a degree, so nothing here
/// is ever rounded.
class Rules {
  /// The sides a face may have on the sham.
  static const sides = [3, 4, 5, 6, 7, 8];

  /// The faces that may meet at the corner on the sham.
  static const faces = [3, 4, 5, 6, 7, 8];

  /// A face's corner, in degrees, as (numerator, p): 180(p - 2)/p.
  static (int, int) angle(int p) => (180 * (p - 2), p);

  /// The angles of q faces summed, in degrees, as (numerator, p).
  static (int, int) sum(int p, int q) => (q * 180 * (p - 2), p);

  /// What the sum leaves of the full turn, in degrees, as (numerator, p);
  /// negative when the faces overlap.
  static (int, int) gap(int p, int q) => (360 * p - q * 180 * (p - 2), p);

  /// Whether q faces of p sides close a corner: the gap is left open.
  static bool closes(int p, int q) => gap(p, q).$1 > 0;

  /// Whether they lie flat, the gap nought exactly.
  static bool flat(int p, int q) => gap(p, q).$1 == 0;

  /// Whether they overlap.
  static bool overlaps(int p, int q) => gap(p, q).$1 < 0;

  /// Euler's count for a solid whose faces have p sides, q to a corner:
  /// (corners, edges, faces), or null when the count is not a whole
  /// positive number, which is when no such solid exists.
  static (int, int, int)? euler(int p, int q) {
    final d = 4 - (p - 2) * (q - 2);
    if (d <= 0) return null;
    if ((4 * p) % d != 0 || (2 * p * q) % d != 0 || (4 * q) % d != 0) return null;
    return (4 * p ~/ d, 2 * p * q ~/ d, 4 * q ~/ d);
  }

  /// The solid's name, for the five that close.
  static String? solid(int p, int q) => switch ((p, q)) {
        (3, 3) => 'the tetrahedron',
        (3, 4) => 'the octahedron',
        (3, 5) => 'the icosahedron',
        (4, 3) => 'the cube',
        (5, 3) => 'the dodecahedron',
        _ => null,
      };

  /// The tiling's name, for the three that lie flat.
  static String? tiling(int p, int q) => switch ((p, q)) {
        (3, 6) => 'the triangle tiling',
        (4, 4) => 'the square tiling',
        (6, 3) => 'the honeycomb',
        _ => null,
      };

  /// A face's name.
  static String face(int p, {bool plural = false}) {
    const names = ['triangle', 'square', 'pentagon', 'hexagon', 'heptagon', 'octagon'];
    final name = names[p - 3];
    return plural ? '${name}s' : name;
  }

  /// A count of faces, told.
  static String count(int q) {
    const words = ['three', 'four', 'five', 'six', 'seven', 'eight'];
    return words[q - 3];
  }

  /// Degrees as words: whole when whole, else a mixed number.
  static String degrees((int, int) d) {
    final (n, p) = d;
    final sign = n < 0 ? '-' : '';
    final a = n.abs();
    final whole = a ~/ p, rest = a % p;
    if (rest == 0) return '$sign$whole';
    final g = _gcd(rest, p);
    return whole == 0 ? '$sign${rest ~/ g}/${p ~/ g}' : '$sign$whole ${rest ~/ g}/${p ~/ g}';
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Every setting of sides and faces on the sham, asked, and how many
  /// met the ask, with the count of settings.
  static (int, int) sweep(bool Function(int p, int q) ask) {
    var met = 0, all = 0;
    for (final p in sides) {
      for (final q in faces) {
        all++;
        if (ask(p, q)) met++;
      }
    }
    return (met, all);
  }

  /// The first setting meeting [ask], sides first, or null.
  static (int, int)? first(bool Function(int p, int q) ask) {
    for (final p in sides) {
      for (final q in faces) {
        if (ask(p, q)) return (p, q);
      }
    }
    return null;
  }
}
