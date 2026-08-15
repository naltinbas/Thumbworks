/// A peg on the rim, by its whole-number place from the hub.
typedef Peg = (int, int);

/// The law of the wheel.
///
/// Twelve pegs stand on the rim of a wheel five spokes across, at
/// the whole-number places whose squares add to twenty-five, and
/// cords run between them. Thales' theorem, the oldest in the book,
/// says a corner on the rim is square exactly when the cord across
/// from it is a diameter, straight through the hub. The sweep here
/// cords every three of the twelve, 220 triangles, and finds sixty
/// with a square corner, every one across a diameter and never
/// otherwise; forty are sharp all round, a hundred and twenty blunt
/// somewhere. Four pegs make a square three ways.
class Rules {
  Rules();

  static const radiusSquared = 25;

  /// The twelve pegs, round the rim.
  static const pegs = <Peg>[
    (5, 0), (4, 3), (3, 4), (0, 5), (-3, 4), (-4, 3),
    (-5, 0), (-4, -3), (-3, -4), (0, -5), (3, -4), (4, -3),
  ];

  static (int, int) diff(Peg a, Peg b) => (a.$1 - b.$1, a.$2 - b.$2);
  static int dot((int, int) u, (int, int) v) => u.$1 * v.$1 + u.$2 * v.$2;

  /// Whether every peg sits on the rim: its squares add to twenty-five.
  static bool onRim(Peg p) => p.$1 * p.$1 + p.$2 * p.$2 == radiusSquared;

  /// Whether the corner at [corner], between cords to [a] and [b],
  /// is square: the dot product of the two cords is nought.
  static bool squareCorner(Peg corner, Peg a, Peg b) =>
      dot(diff(a, corner), diff(b, corner)) == 0;

  /// Whether the cord from [a] to [b] is a diameter: it runs through
  /// the hub, the two pegs across from one another.
  static bool isDiameter(Peg a, Peg b) => a.$1 + b.$1 == 0 && a.$2 + b.$2 == 0;

  /// The corners of a triangle that are square, as indexes 0 to 2.
  static List<int> squareCorners(List<Peg> three) => [
        for (var i = 0; i < 3; i++)
          if (squareCorner(three[i], three[(i + 1) % 3], three[(i + 2) % 3])) i,
      ];

  /// The corners across from a diameter, as indexes 0 to 2: Thales'
  /// reading, no angle measured.
  static List<int> cornersAcrossDiameters(List<Peg> three) => [
        for (var i = 0; i < 3; i++)
          if (isDiameter(three[(i + 1) % 3], three[(i + 2) % 3])) i,
      ];

  /// Whether every corner is sharp: every dot product positive.
  static bool sharp(List<Peg> three) {
    for (var i = 0; i < 3; i++) {
      if (dot(diff(three[(i + 1) % 3], three[i]), diff(three[(i + 2) % 3], three[i])) <= 0) return false;
    }
    return true;
  }

  /// Whether four pegs, in some order, make a square.
  static bool makesSquare(List<Peg> four) {
    for (final order in _orders(four)) {
      final a = order[0], b = order[1], c = order[2], d = order[3];
      final ab = diff(b, a), ad = diff(d, a), dc = diff(c, d);
      if (ab == dc && dot(ab, ad) == 0 && dot(ab, ab) == dot(ad, ad)) return true;
    }
    return false;
  }

  static Iterable<List<Peg>> _orders(List<Peg> four) sync* {
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 4; j++) {
        if (j == i) continue;
        for (var k = 0; k < 4; k++) {
          if (k == i || k == j) continue;
          final l = 6 - i - j - k;
          yield [four[i], four[j], four[k], four[l]];
        }
      }
    }
  }

  /// Every three of the twelve, as index triples i < j < k; calls
  /// [visit].
  static void triples(void Function(List<Peg>) visit) {
    for (var i = 0; i < 12; i++) {
      for (var j = i + 1; j < 12; j++) {
        for (var k = j + 1; k < 12; k++) {
          visit([pegs[i], pegs[j], pegs[k]]);
        }
      }
    }
  }

  /// Every four of the twelve; calls [visit].
  static void quads(void Function(List<Peg>) visit) {
    for (var i = 0; i < 12; i++) {
      for (var j = i + 1; j < 12; j++) {
        for (var k = j + 1; k < 12; k++) {
          for (var l = k + 1; l < 12; l++) {
            visit([pegs[i], pegs[j], pegs[k], pegs[l]]);
          }
        }
      }
    }
  }
}
