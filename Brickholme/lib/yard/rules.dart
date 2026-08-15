/// A brick: three flags in a row, laid across or down from its first
/// flag, the flags numbered row by row from the top left.
typedef Brick = (int, bool);

/// The law of the yard: n by n flags, one of them a drain, and bricks
/// three flags long to pave the rest.
class Rules {
  const Rules(this.side, this.drain);

  /// Flags along a side.
  final int side;

  /// The drain's flag.
  final int drain;

  int get flags => side * side;

  int rowOf(int c) => c ~/ side;

  int colOf(int c) => c % side;

  int at(int row, int col) => row * side + col;

  /// The three flags a brick covers, or null when it runs off the yard.
  List<int>? flagsOf(Brick brick) {
    final (c, across) = brick;
    final r = rowOf(c), k = colOf(c);
    if (across) {
      if (k + 2 >= side) return null;
      return [c, c + 1, c + 2];
    }
    if (r + 2 >= side) return null;
    return [c, c + side, c + 2 * side];
  }

  /// The flags [bricks] cover, told once each even where bricks lie on
  /// one another.
  Set<int> covered(Iterable<Brick> bricks) => {
        for (final b in bricks) ...?flagsOf(b),
      };

  /// Every pair of bricks lying on a common flag, or on the drain.
  List<(Brick, Brick)> clashes(List<Brick> bricks) {
    final out = <(Brick, Brick)>[];
    for (var i = 0; i < bricks.length; i++) {
      final a = flagsOf(bricks[i]);
      if (a == null) continue;
      for (var j = i + 1; j < bricks.length; j++) {
        final b = flagsOf(bricks[j]);
        if (b == null) continue;
        if (a.any(b.contains)) out.add((bricks[i], bricks[j]));
      }
    }
    return out;
  }

  /// Whether a brick may be laid: on the yard, off the drain, and on no
  /// flag already covered.
  bool fits(Brick brick, Iterable<Brick> laid) {
    final f = flagsOf(brick);
    if (f == null || f.contains(drain)) return false;
    final taken = covered(laid);
    return !f.any(taken.contains);
  }

  /// Whether the yard is paved: every flag but the drain under exactly one brick.
  bool paved(List<Brick> bricks) {
    if (clashes(bricks).isNotEmpty) return false;
    final taken = covered(bricks);
    return taken.length == flags - 1 && !taken.contains(drain);
  }

  /// Every brick that fits with [laid] down.
  List<Brick> openings(List<Brick> laid) => [
        for (var c = 0; c < flags; c++)
          for (final across in [true, false])
            if (fits((c, across), laid)) (c, across),
      ];

  /// The count of pavings, by a walk row by row: each column carries how
  /// many more rows the brick standing in it reaches down, nought, one or
  /// two, and each row is filled left to right, a brick across or one
  /// down starting at every open flag.
  int pavings() {
    var states = <int, int>{0: 1}; // pending, packed in base three, to count
    for (var r = 0; r < side; r++) {
      final next = <int, int>{};
      for (final entry in states.entries) {
        final pending = List<int>.filled(side, 0);
        var code = entry.key;
        for (var k = 0; k < side; k++) {
          pending[k] = code % 3;
          code ~/= 3;
        }
        _fillRow(r, 0, pending, List<int>.filled(side, 0), entry.value, next);
      }
      states = next;
    }
    return states[0] ?? 0;
  }

  void _fillRow(int r, int k, List<int> pending, List<int> below, int ways, Map<int, int> next) {
    if (k == side) {
      var code = 0;
      for (var i = side - 1; i >= 0; i--) {
        code = code * 3 + below[i];
      }
      next[code] = (next[code] ?? 0) + ways;
      return;
    }
    if (pending[k] > 0) {
      below[k] = pending[k] - 1;
      _fillRow(r, k + 1, pending, below, ways, next);
      below[k] = 0;
      return;
    }
    if (at(r, k) == drain) {
      below[k] = 0;
      _fillRow(r, k + 1, pending, below, ways, next);
      return;
    }
    // A brick down from here.
    if (r + 2 < side && at(r + 1, k) != drain && at(r + 2, k) != drain) {
      below[k] = 2;
      _fillRow(r, k + 1, pending, below, ways, next);
      below[k] = 0;
    }
    // A brick across from here.
    if (k + 2 < side && pending[k + 1] == 0 && pending[k + 2] == 0 && at(r, k + 1) != drain && at(r, k + 2) != drain) {
      below[k] = 0;
      below[k + 1] = 0;
      below[k + 2] = 0;
      _fillRow(r, k + 3, pending, below, ways, next);
    }
  }

  /// A paving found by walking, first bare flag first, or null.
  List<Brick>? paving() {
    final laid = <Brick>[];
    final taken = <int>{};
    bool go() {
      var c = 0;
      while (c < flags && (c == drain || taken.contains(c))) {
        c++;
      }
      if (c == flags) return true;
      for (final across in [true, false]) {
        final f = flagsOf((c, across));
        if (f == null || f.contains(drain) || f.any(taken.contains)) continue;
        taken.addAll(f);
        laid.add((c, across));
        if (go()) return true;
        laid.removeLast();
        taken.removeAll(f);
      }
      return false;
    }

    return go() ? laid : null;
  }

  /// The colouring: flag (row, col) takes colour (row + col) mod 3, or
  /// (row - col) mod 3 for the other slant; a brick three long, across or
  /// down, always covers one flag of each colour.
  int colour(int c, {required bool sum}) => sum ? (rowOf(c) + colOf(c)) % 3 : ((rowOf(c) - colOf(c)) % 3 + 3) % 3;

  /// How many flags of each colour, drain and all.
  List<int> counts({required bool sum}) {
    final out = [0, 0, 0];
    for (var c = 0; c < flags; c++) {
      out[colour(c, sum: sum)]++;
    }
    return out;
  }

  /// The colour with one flag more than the others, when there is one:
  /// the yard less the drain paves only if the drain wears it.
  int? oddColour({required bool sum}) {
    final n = counts(sum: sum);
    for (var i = 0; i < 3; i++) {
      if (n[i] == n[(i + 1) % 3] + 1 && n[i] == n[(i + 2) % 3] + 1) return i;
    }
    return null;
  }

  /// What the colouring says: the flags less the drain divide by three,
  /// and the drain wears the odd colour of both slants.
  bool get colouringAllows {
    if ((flags - 1) % 3 != 0) return false;
    final a = oddColour(sum: true), b = oddColour(sum: false);
    return a != null && b != null && colour(drain, sum: true) == a && colour(drain, sum: false) == b;
  }
}
