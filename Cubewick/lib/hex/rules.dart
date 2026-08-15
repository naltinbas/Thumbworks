/// A unit triangle of the grid: up or down, at lattice cell (i, j).
typedef Tri = (bool up, int i, int j);

/// A lozenge: an up triangle and the down triangle it is glued to.
typedef Lozenge = (Tri, Tri);

/// A hexagon of sides a, b and c on the triangular grid, and the law
/// of lozenges on it: every lozenge is one up triangle and one down
/// triangle sharing an edge, and a tiling covers every triangle once.
class Hexagon {
  Hexagon(this.a, this.b, this.c, {this.chipped = const []}) {
    ups = [
      for (var i = -c; i < a; i++)
        for (var j = 0; j < b + c; j++)
          if (i + j >= 0 && i + j + 1 <= a + b && !chipped.contains((true, i, j))) (true, i, j),
    ];
    downs = [
      for (var i = -c; i < a; i++)
        for (var j = 0; j < b + c; j++)
          if (i + j + 1 >= 0 && i + j + 2 <= a + b && !chipped.contains((false, i, j))) (false, i, j),
    ];
  }

  final int a;
  final int b;
  final int c;

  /// Triangles taken out of the hexagon.
  final List<Tri> chipped;

  late final List<Tri> ups;
  late final List<Tri> downs;

  List<Tri> get triangles => [...ups, ...downs];

  bool holds(Tri t) => t.$1 ? ups.contains(t) : downs.contains(t);

  /// The three down triangles an up triangle can be glued to: across
  /// its slanted edge, its bottom edge and its left edge, in that order.
  static List<Tri> mates(Tri up) {
    final (_, i, j) = up;
    return [(false, i, j), (false, i, j - 1), (false, i - 1, j)];
  }

  static bool neighbours(Tri x, Tri y) {
    if (x.$1 == y.$1) return false;
    final up = x.$1 ? x : y;
    final down = x.$1 ? y : x;
    return mates(up).contains(down);
  }

  /// The lozenge two triangles make, up first, or null when they do
  /// not share an edge.
  Lozenge? lozenge(Tri x, Tri y) {
    if (!neighbours(x, y) || !holds(x) || !holds(y)) return null;
    return x.$1 ? (x, y) : (y, x);
  }

  /// The way a lozenge leans: 0 across the slanted edge, which reads as
  /// the top face of a cube, 1 across the bottom edge, the left face,
  /// and 2 across the left edge, the right face.
  static int lean(Lozenge l) => mates(l.$1).indexOf(l.$2);

  /// Every tiling of the hexagon, visited in turn as lists of lozenges,
  /// up triangles taken in order and each glued to a free mate.
  void tilings(void Function(List<Lozenge>) visit) {
    final free = {...downs};
    final laid = <Lozenge>[];
    void grow(int k) {
      if (k == ups.length) {
        visit(laid);
        return;
      }
      final up = ups[k];
      for (final d in mates(up)) {
        if (!free.remove(d)) continue;
        laid.add((up, d));
        grow(k + 1);
        laid.removeLast();
        free.add(d);
      }
    }

    if (ups.length == downs.length) grow(0);
  }

  int count() {
    var n = 0;
    tilings((_) => n++);
    return n;
  }

  /// The first tiling, or null.
  List<Lozenge>? first() {
    List<Lozenge>? found;
    tilings((t) => found ??= List.of(t));
    return found;
  }

  /// MacMahon's count, with no sweep at all: the product over i to a,
  /// j to b, k to c of (i + j + k - 1) over (i + j + k - 2), which is
  /// the count of stacks of cubes in an a by b by c box.
  static int macmahon(int a, int b, int c) {
    var num = BigInt.one, den = BigInt.one;
    for (var i = 1; i <= a; i++) {
      for (var j = 1; j <= b; j++) {
        for (var k = 1; k <= c; k++) {
          num *= BigInt.from(i + j + k - 1);
          den *= BigInt.from(i + j + k - 2);
        }
      }
    }
    return (num ~/ den).toInt();
  }

  /// The stacks of cubes in an a by b by c box, counted by walking every
  /// one: heights on an a by b floor, no higher than c, never rising
  /// away from the back corner.
  static int stacks(int a, int b, int c) {
    var n = 0;
    final h = List.generate(a, (_) => List.filled(b, 0));
    void grow(int cell) {
      if (cell == a * b) {
        n++;
        return;
      }
      final r = cell ~/ b, col = cell % b;
      final cap = [
        c,
        if (r > 0) h[r - 1][col],
        if (col > 0) h[r][col - 1],
      ].reduce((x, y) => x < y ? x : y);
      for (var v = 0; v <= cap; v++) {
        h[r][col] = v;
        grow(cell + 1);
      }
      h[r][col] = 0;
    }

    grow(0);
    return n;
  }
}
