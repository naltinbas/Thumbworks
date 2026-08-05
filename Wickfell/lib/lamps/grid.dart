/// A grid of lamps, and what pressing one does.
///
/// Which lamps are lit is one number: a bit for each, so a board is a value
/// that can be compared, put in a set and exclusive-ored with another. That
/// last one is the whole game — pressing a lamp is exclusive-or with a fixed
/// number, so the order of the presses cannot matter and pressing the same
/// lamp twice is the same as never pressing it at all.
class Grid {
  Grid(this.across, this.down) : presses = _pressesFor(across, down);

  final int across;
  final int down;

  /// What each lamp's press changes, as a number with a bit set for the lamp
  /// itself and for the ones it touches.
  final List<int> presses;

  int get lamps => across * down;

  /// Every lamp lit, which is what a board that is not finished looks like at
  /// its worst.
  int get all => (1 << lamps) - 1;

  int columnOf(int at) => at % across;
  int rowOf(int at) => at ~/ across;

  bool isLit(int board, int at) => board >> at & 1 == 1;

  /// The board after a lamp is pressed.
  int pressed(int board, int at) => board ^ presses[at];

  /// The board after a whole set of presses, which does not depend on their
  /// order.
  int afterAll(int board, Iterable<int> which) {
    var now = board;
    for (final at in which) {
      now = pressed(now, at);
    }
    return now;
  }

  /// How many lamps are lit.
  int litOn(int board) {
    var found = 0;
    var left = board;
    while (left != 0) {
      found += left & 1;
      left >>= 1;
    }
    return found;
  }

  static List<int> _pressesFor(int across, int down) {
    final presses = <int>[];
    for (var at = 0; at < across * down; at++) {
      final row = at ~/ across;
      final column = at % across;
      var mask = 1 << at;
      for (final step in const [(0, -1), (0, 1), (-1, 0), (1, 0)]) {
        final r = row + step.$1;
        final c = column + step.$2;
        if (r < 0 || r >= down || c < 0 || c >= across) continue;
        mask |= 1 << (r * across + c);
      }
      presses.add(mask);
    }
    return presses;
  }
}
