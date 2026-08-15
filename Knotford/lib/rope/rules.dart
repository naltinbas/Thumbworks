/// Three sides round the pegs, in the order the rope runs.
typedef Sides = (int, int, int);

/// A rope of so many knots, tied in a loop, and what it does when it
/// is stretched round three pegs.
class Rules {
  const Rules(this.knots);

  /// Knots on the loop, one gap between each pair, so the three sides
  /// add up to this.
  final int knots;

  /// The sides when pegs stand at knots [i] and [j], counting from
  /// the peg at knot nought: [i] along, [j] minus [i] on, and the rest
  /// back home.
  Sides sidesOf(int i, int j) => (i, j - i, knots - j);

  /// The longest side, which is the one across from the corner that
  /// might be square.
  static int longest(Sides s) => [s.$1, s.$2, s.$3].reduce((a, b) => a > b ? a : b);

  /// Whether three sides close into a triangle at all: the two
  /// shorter must outreach the longest.
  static bool closes(Sides s) => s.$1 + s.$2 + s.$3 > 2 * longest(s);

  /// The two shorter sides squared and added, less the longest
  /// squared: nought at a square corner, more when the corner is
  /// sharp, less when it is blunt.
  static int shortfall(Sides s) {
    final c = longest(s);
    return s.$1 * s.$1 + s.$2 * s.$2 + s.$3 * s.$3 - 2 * c * c;
  }

  static bool square(Sides s) => closes(s) && shortfall(s) == 0;

  /// The sides sorted, small to large: the triangle without its order.
  static (int, int, int) sorted(Sides s) {
    final l = [s.$1, s.$2, s.$3]..sort();
    return (l[0], l[1], l[2]);
  }

  /// Every way of standing the two pegs, knot [i] then knot [j] past
  /// it, with the third peg at knot nought.
  void markings(void Function(int i, int j) visit) {
    for (var i = 1; i < knots; i++) {
      for (var j = i + 1; j < knots; j++) {
        visit(i, j);
      }
    }
  }

  int get markingCount => (knots - 1) * (knots - 2) ~/ 2;

  /// The sweep: markings that square the corner, and the triangles
  /// they make, sides sorted.
  (int, Set<(int, int, int)>) sweep() {
    var ways = 0;
    final triangles = <(int, int, int)>{};
    markings((i, j) {
      final s = sidesOf(i, j);
      if (square(s)) {
        ways++;
        triangles.add(sorted(s));
      }
    });
    return (ways, triangles);
  }

  /// The first marking that squares the corner, or null.
  (int, int)? landing() {
    (int, int)? found;
    markings((i, j) {
      if (found == null && square(sidesOf(i, j))) found = (i, j);
    });
    return found;
  }

  /// Euclid's triangles for this rope, with no sweep at all: every
  /// right triangle with whole sides is k times (m*m - n*n, 2mn,
  /// m*m + n*n) for m > n > 0 coprime and not both odd, and its knots
  /// come to 2km(m + n).
  static Set<(int, int, int)> euclid(int knots) {
    final found = <(int, int, int)>{};
    for (var m = 2; 2 * m * (m + 1) <= knots; m++) {
      for (var n = 1; n < m; n++) {
        if ((m - n).isEven || _gcd(m, n) != 1) continue;
        final perimeter = 2 * m * (m + n);
        if (knots % perimeter != 0) continue;
        final k = knots ~/ perimeter;
        final l = [k * (m * m - n * n), k * 2 * m * n, k * (m * m + n * n)]..sort();
        found.add((l[0], l[1], l[2]));
      }
    }
    return found;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Squares leave nought or one when divided by four, so two squares
  /// adding to a third fix the sides' parities: this walks every way
  /// three remainders can fall and reads off that the knots come even
  /// whenever the corner can be square.
  static bool oddRopeNeverSquares() {
    for (var a = 0; a < 4; a++) {
      for (var b = 0; b < 4; b++) {
        for (var c = 0; c < 4; c++) {
          if ((a * a + b * b - c * c) % 4 == 0 && (a + b + c).isOdd) return false;
        }
      }
    }
    return true;
  }
}
