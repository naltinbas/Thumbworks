/// The arithmetic of the green: an equilateral triangle of side n on
/// the triangular lattice, a point of the lattice inside it or on it,
/// and the point's three distances to the sides, measured in rungs, a
/// rung being the height over n. Two voices: the rungs read straight
/// off the lattice, the point's row above each side; and the areas, the
/// three triangles the point makes with the sides adding to the whole
/// green, worked as whole numbers of lattice cells, which is the reason
/// the rungs add to n.
class Rules {
  /// The side of the green, in lattice steps.
  static const side = 12;

  /// The lattice points inside the green or on it, as (a, b, c) rungs
  /// from the three sides, a + b + c = side: a from the floor, b from the
  /// right slope, c from the left slope. In order, floor rungs first.
  static List<(int, int, int)> get points => [
        for (var a = 0; a <= side; a++)
          for (var b = 0; a + b <= side; b++) (a, b, side - a - b),
      ];

  /// How many points there are: (side + 1)(side + 2)/2.
  static int get count => (side + 1) * (side + 2) ~/ 2;

  /// The rungs added, the first voice: always the side.
  static int rungsAdded((int, int, int) p) => p.$1 + p.$2 + p.$3;

  /// The point in lattice coordinates (x, y): x steps along the floor
  /// and y rows up, the floor being y = 0, the left slope x = y/2 ... in
  /// doubled units so everything is whole: X = 2x + y, Y = y, with the
  /// green's corners at (0, 0), (2n, 0) and (n, n) in doubled units.
  static (int, int) doubled((int, int, int) p) {
    final (a, b, c) = p;
    // Rows up from the floor: a. Along the floor from the left corner:
    // c steps past the left slope's foot at height a, whose doubled X is
    // a; so X = a + 2c, Y = a.
    return (a + 2 * c, a);
  }

  /// Twice the area of a triangle in doubled coordinates, as a whole
  /// number of lattice cells scaled: the shoelace on (X, Y) with the
  /// green's own scale, so the whole green comes to 2 n^2 and each
  /// sub-triangle to a whole share.
  static int twiceArea((int, int) p, (int, int) q, (int, int) r) => ((q.$1 - p.$1) * (r.$2 - p.$2) - (r.$1 - p.$1) * (q.$2 - p.$2)).abs();

  /// The three sub-triangle areas of a point with the sides, in the same
  /// scale, floor first, then the right slope, then the left; the second
  /// voice.
  static (int, int, int) areas((int, int, int) p) {
    final d = doubled(p);
    const left = (0, 0), right = (2 * side, 0), top = (side, side);
    return (twiceArea(d, left, right), twiceArea(d, right, top), twiceArea(d, top, left));
  }

  static int get wholeArea => twiceArea((0, 0), (2 * side, 0), (side, side));

  /// A distance in rungs, from an area: the area over the whole, times
  /// the side, since each sub-triangle stands on a full side.
  static bool areasSayRungs((int, int, int) p) {
    final (fa, fb, fc) = areas(p);
    return fa * side == p.$1 * wholeArea && fb * side == p.$2 * wholeArea && fc * side == p.$3 * wholeArea;
  }

  /// A point told: 'floor 4, right slope 4, left slope 4'.
  static String told((int, int, int) p) => 'floor ${p.$1}, right slope ${p.$2}, left slope ${p.$3}';
}
