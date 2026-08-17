/// A hall with a post at each corner and a peg standing anywhere on the
/// field, inside the hall or out of it.
///
/// The posts are A at the near left, B at the near right, C at the far
/// right and D at the far left. Take the square of the distance from
/// the peg to each post. The British flag theorem is that the two
/// opposite pairs come to the same thing: PA squared plus PC squared
/// equals PB squared plus PD squared, wherever the peg stands, so long
/// as the hall's corners are square.
///
/// Lean the far wall over and it stops being true, and by exactly the
/// same amount everywhere: the two sums then differ by twice the lean
/// times the width, whatever the peg does.
class Rules {
  /// The halls the dials allow, in paces.
  static const leastSide = 2, mostSide = 8;

  /// The field the peg can stand on.
  static const low = -3, high = 11;

  /// Where the four posts stand for a hall [wide] by [tall] with the
  /// far wall leaned over by [lean].
  static List<(int, int)> posts(int wide, int tall, int lean) => [
        (0, 0),
        (wide, 0),
        (wide + lean, tall),
        (lean, tall),
      ];

  static const names = ['A', 'B', 'C', 'D'];

  static bool onField(int x, int y) =>
      x >= low && x <= high && y >= low && y <= high;

  static bool validHall(int wide, int tall) =>
      wide >= leastSide && wide <= mostSide &&
      tall >= leastSide && tall <= mostSide;

  /// The square of the distance from the peg at [px], [py] to post
  /// [which].
  static int squareTo(int wide, int tall, int lean, int px, int py, int which) {
    final (x, y) = posts(wide, tall, lean)[which];
    return (px - x) * (px - x) + (py - y) * (py - y);
  }

  /// The four squared distances, A to D.
  static List<int> squares(int wide, int tall, int lean, int px, int py) => [
        for (var which = 0; which < 4; which++)
          squareTo(wide, tall, lean, px, py, which),
      ];

  /// The first pair, A and C.
  static int acrossOne(int wide, int tall, int lean, int px, int py) =>
      squareTo(wide, tall, lean, px, py, 0) +
      squareTo(wide, tall, lean, px, py, 2);

  /// The second pair, B and D.
  static int acrossTwo(int wide, int tall, int lean, int px, int py) =>
      squareTo(wide, tall, lean, px, py, 1) +
      squareTo(wide, tall, lean, px, py, 3);

  /// The same two sums worked out without any distance at all, by
  /// multiplying the brackets out: the second voice. For a hall leaned
  /// over by [lean] the difference comes to twice the lean times the
  /// width, and nothing else.
  static (int, int) sumsByAlgebra(
      int wide, int tall, int lean, int px, int py) {
    // A at (0, 0), C at (wide + lean, tall): the cross terms in x and y
    // cancel against B at (wide, 0) and D at (lean, tall) except for the
    // lean.
    final both = 2 * px * px +
        2 * py * py +
        (wide + lean) * (wide + lean) +
        tall * tall -
        2 * px * (wide + lean) -
        2 * py * tall;
    final other = both - 2 * lean * wide;
    return (both, other);
  }

  /// How far apart the two sums are: nought for a square-cornered hall.
  static int apart(int wide, int tall, int lean, int px, int py) =>
      acrossOne(wide, tall, lean, px, py) -
      acrossTwo(wide, tall, lean, px, py);

  /// Whether [n] is a square, so the distance itself is a whole number
  /// of paces.
  static bool isSquare(int n) {
    if (n < 0) return false;
    var root = 0;
    while (root * root < n) {
      root++;
    }
    return root * root == n;
  }

  static int rootOf(int n) {
    var root = 0;
    while (root * root < n) {
      root++;
    }
    return root;
  }

  /// Whether every one of the four distances is a whole number.
  static bool allWhole(int wide, int tall, int lean, int px, int py) =>
      squares(wide, tall, lean, px, py).every(isSquare);

  /// Whether all four distances are the same.
  static bool allSame(int wide, int tall, int lean, int px, int py) =>
      squares(wide, tall, lean, px, py).toSet().length == 1;

  /// Whether the peg stands inside the hall, off the walls.
  static bool inside(int wide, int tall, int lean, int px, int py) {
    if (lean != 0) {
      // The leaned hall is a slanted box: the peg is inside when it is
      // between the two slanting walls and the two level ones.
      final along = px * tall - py * lean;
      return py > 0 && py < tall && along > 0 && along < wide * tall;
    }
    return px > 0 && px < wide && py > 0 && py < tall;
  }

  /// Every hall and every standing the game allows.
  static Iterable<(int, int, int, int)> settings() sync* {
    for (var wide = leastSide; wide <= mostSide; wide++) {
      for (var tall = leastSide; tall <= mostSide; tall++) {
        for (var px = low; px <= high; px++) {
          for (var py = low; py <= high; py++) {
            yield (wide, tall, px, py);
          }
        }
      }
    }
  }

  static int get howMany =>
      (mostSide - leastSide + 1) *
      (mostSide - leastSide + 1) *
      (high - low + 1) *
      (high - low + 1);

  static String tellSquares(List<int> squares) => squares
      .map((square) => isSquare(square) ? '${rootOf(square)}' : 'root $square')
      .join(', ');
}
