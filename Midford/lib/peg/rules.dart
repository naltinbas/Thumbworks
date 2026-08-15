/// A peg on the board, x across and y down.
typedef Peg = (int, int);

/// The law of the cords.
///
/// Four pegs set in order, a cord run from each to the next and
/// back to the first, and the midpoints of the four cords joined
/// in their turn. Varignon saw in 1731 that the midpoint figure is
/// always a parallelogram, whatever four pegs you set: the cord
/// from the first midpoint to the second is half the diagonal from
/// the first peg to the third, and so is the cord from the fourth
/// midpoint to the third, so those two are equal and parallel. The
/// midpoint figure is a rectangle exactly when the two diagonals
/// cross square, a rhombus exactly when they are of a length, and a
/// square when both. It is never skew, and the sweep of every
/// ordered four on the board finds none.
class Rules {
  Rules({this.side = 5});

  final int side;

  List<Peg> get pegs => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) (x, y),
      ];

  static (int, int) diff(Peg a, Peg b) => (a.$1 - b.$1, a.$2 - b.$2);
  static int dot((int, int) u, (int, int) v) => u.$1 * v.$1 + u.$2 * v.$2;
  static int cross((int, int) u, (int, int) v) => u.$1 * v.$2 - u.$2 * v.$1;

  /// The midpoints of the four cords, doubled so they stay whole:
  /// the midpoint of a and b is (a + b) over two.
  static List<(int, int)> midpointsDoubled(List<Peg> four) => [
        for (var i = 0; i < 4; i++)
          (four[i].$1 + four[(i + 1) % 4].$1, four[i].$2 + four[(i + 1) % 4].$2),
      ];

  /// The first diagonal, first peg to third, and the second, second
  /// peg to fourth.
  static (int, int) firstDiagonal(List<Peg> four) => diff(four[2], four[0]);
  static (int, int) secondDiagonal(List<Peg> four) => diff(four[3], four[1]);

  /// Whether the midpoint figure is a parallelogram, read off the
  /// midpoints themselves: the first side and the third side are the
  /// same vector.
  static bool parallelogramByMidpoints(List<Peg> four) {
    final m = midpointsDoubled(four);
    final side1 = (m[1].$1 - m[0].$1, m[1].$2 - m[0].$2);
    final side3 = (m[2].$1 - m[3].$1, m[2].$2 - m[3].$2);
    return side1 == side3;
  }

  /// Varignon's reason, as arithmetic: the first side of the midpoint
  /// figure, doubled, is the first diagonal, and so is the third.
  static bool varignonHolds(List<Peg> four) {
    final m = midpointsDoubled(four);
    final side1 = (m[1].$1 - m[0].$1, m[1].$2 - m[0].$2);
    final side3 = (m[2].$1 - m[3].$1, m[2].$2 - m[3].$2);
    final d = firstDiagonal(four);
    return side1 == d && side3 == d;
  }

  /// Whether the four pegs make a figure at all: the diagonals are not
  /// parallel, so the midpoint figure has room in it.
  static bool hasRoom(List<Peg> four) =>
      cross(firstDiagonal(four), secondDiagonal(four)) != 0;

  /// The midpoint figure is a rectangle when the diagonals cross square.
  static bool rectangleByDiagonals(List<Peg> four) =>
      hasRoom(four) && dot(firstDiagonal(four), secondDiagonal(four)) == 0;

  /// The same, read off the midpoint figure: its first corner is
  /// square.
  static bool rectangleByMidpoints(List<Peg> four) {
    if (!hasRoom(four)) return false;
    final m = midpointsDoubled(four);
    final a = (m[1].$1 - m[0].$1, m[1].$2 - m[0].$2);
    final b = (m[3].$1 - m[0].$1, m[3].$2 - m[0].$2);
    return dot(a, b) == 0;
  }

  /// A rhombus when the diagonals are of a length.
  static bool rhombusByDiagonals(List<Peg> four) {
    if (!hasRoom(four)) return false;
    final d1 = firstDiagonal(four), d2 = secondDiagonal(four);
    return dot(d1, d1) == dot(d2, d2);
  }

  /// The same, read off the midpoint figure: two neighbouring sides
  /// of a length.
  static bool rhombusByMidpoints(List<Peg> four) {
    if (!hasRoom(four)) return false;
    final m = midpointsDoubled(four);
    final a = (m[1].$1 - m[0].$1, m[1].$2 - m[0].$2);
    final b = (m[3].$1 - m[0].$1, m[3].$2 - m[0].$2);
    return dot(a, a) == dot(b, b);
  }

  static bool squareByDiagonals(List<Peg> four) =>
      rectangleByDiagonals(four) && rhombusByDiagonals(four);

  /// Every ordered four of distinct pegs on the board; calls [visit].
  void fours(void Function(List<Peg>) visit) {
    final all = pegs;
    final four = <Peg>[];
    void pick() {
      if (four.length == 4) {
        visit(four);
        return;
      }
      for (final peg in all) {
        if (four.contains(peg)) continue;
        four.add(peg);
        pick();
        four.removeLast();
      }
    }

    pick();
  }
}
