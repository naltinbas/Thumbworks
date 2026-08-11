/// The law of the floor.
///
/// A room is a set of cells on a grid, and a plank covers two cells
/// side by side or one atop the other. The floor is laid when every
/// cell is covered, no plank crossing the room's edge and none
/// overlapping.
///
/// What can be laid is known by counting every tiling outright, and
/// the room's two colours say the same thing the cheap way: every
/// plank covers one cell of each colour, so a room with uneven
/// colours can never be floored.
class Rules {
  Rules(this.wide, this.high, this.cells);

  final int wide;
  final int high;

  /// The room's cells, as a bitmask over the grid, bit = row * wide +
  /// column.
  final int cells;

  bool inRoom(int cell) => cells & (1 << cell) != 0;

  int get cellCount {
    var count = 0;
    var bits = cells;
    while (bits != 0) {
      bits &= bits - 1;
      count++;
    }
    return count;
  }

  /// The checkerboard colours: how many dark cells, how many light.
  (int, int) colours() {
    var dark = 0;
    var light = 0;
    for (var cell = 0; cell < wide * high; cell++) {
      if (!inRoom(cell)) continue;
      if ((cell % wide + cell ~/ wide).isEven) {
        dark++;
      } else {
        light++;
      }
    }
    return (dark, light);
  }

  final _counted = <int, int>{};

  /// How many ways the uncovered cells can be planked, counted by
  /// taking the first empty cell and trying its two mates.
  int tilings(int uncovered) {
    if (uncovered == 0) return 1;
    final known = _counted[uncovered];
    if (known != null) return known;
    // The lowest uncovered cell must be covered by a plank going
    // right or down.
    var cell = 0;
    while (uncovered & (1 << cell) == 0) {
      cell++;
    }
    var count = 0;
    final right = cell + 1;
    if (cell % wide < wide - 1 && uncovered & (1 << right) != 0) {
      count += tilings(uncovered & ~(1 << cell) & ~(1 << right));
    }
    final down = cell + wide;
    if (down < wide * high && uncovered & (1 << down) != 0) {
      count += tilings(uncovered & ~(1 << cell) & ~(1 << down));
    }
    return _counted[uncovered] = count;
  }

  /// Whether the uncovered cells can still be planked at all.
  bool canStill(int uncovered) => tilings(uncovered) > 0;

  /// A plank from some full laying of the uncovered cells: the two
  /// cells it covers, or null when nothing lays.
  (int, int)? next(int uncovered) {
    if (uncovered == 0) return null;
    var cell = 0;
    while (uncovered & (1 << cell) == 0) {
      cell++;
    }
    final right = cell + 1;
    if (cell % wide < wide - 1 &&
        uncovered & (1 << right) != 0 &&
        canStill(uncovered & ~(1 << cell) & ~(1 << right))) {
      return (cell, right);
    }
    final down = cell + wide;
    if (down < wide * high &&
        uncovered & (1 << down) != 0 &&
        canStill(uncovered & ~(1 << cell) & ~(1 << down))) {
      return (cell, down);
    }
    return null;
  }

  /// A full rectangle's cells.
  static int rectangle(int wide, int high) => (1 << (wide * high)) - 1;
}
