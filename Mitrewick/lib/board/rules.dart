/// A square of the board, (row, column) from the top left.
typedef Square = (int, int);

/// A board of so many squares a side, and the law of bishops on it:
/// two bishops clash when they share a diagonal either way.
class Rules {
  const Rules(this.side);

  final int side;

  List<Square> get squares => [
        for (var r = 0; r < side; r++)
          for (var c = 0; c < side; c++) (r, c),
      ];

  /// The rising diagonal a square lies on, numbered by row plus
  /// column: there are 2 * side - 1 of them.
  static int rising(Square s) => s.$1 + s.$2;

  /// The falling diagonal, numbered by row less column plus the side.
  int falling(Square s) => s.$1 - s.$2 + side - 1;

  static bool clash(Square a, Square b) => a != b && (rising(a) == rising(b) || a.$1 - a.$2 == b.$1 - b.$2);

  /// The pairs of bishops that clash, by index.
  static List<(int, int)> clashes(List<Square> bishops) => [
        for (var i = 0; i < bishops.length; i++)
          for (var j = i + 1; j < bishops.length; j++)
            if (clash(bishops[i], bishops[j])) (i, j),
      ];

  static bool peaceful(List<Square> bishops) => clashes(bishops).isEmpty;

  /// The rising diagonals held by the bishops, distinct.
  int risingUsed(List<Square> bishops) => bishops.map(rising).toSet().length;

  /// Every way of setting [count] bishops on the board, visited in
  /// turn, squares in reading order.
  void settings(int count, void Function(List<Square>) visit) {
    final all = squares;
    final held = <Square>[];
    void pick(int from) {
      if (held.length == count) {
        visit(held);
        return;
      }
      for (var i = from; i < all.length; i++) {
        if (all.length - i < count - held.length) break;
        held.add(all[i]);
        pick(i + 1);
        held.removeLast();
      }
    }

    pick(0);
  }

  static int choose(int n, int k) {
    if (k < 0 || k > n) return 0;
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }

  /// The sweep: settings of [count] with no clash, and settings in all.
  (int, int) sweep(int count) {
    var peace = 0, all = 0;
    settings(count, (bishops) {
      all++;
      if (peaceful(bishops)) peace++;
    });
    return (peace, all);
  }

  /// The first peaceful setting of [count], or null.
  List<Square>? landing(int count) {
    List<Square>? found;
    settings(count, (bishops) {
      if (found == null && peaceful(bishops)) found = List.of(bishops);
    });
    return found;
  }

  /// The peaceful settings of [count] bishops counted with no sweep of
  /// squares at all: one bishop at most to a rising diagonal, and the
  /// falling diagonals distinct, walked diagonal by diagonal.
  int peacefulByDiagonals(int count) {
    var ways = 0;
    final fallingUsed = <int>{};
    void walk(int diagonal, int placed) {
      if (placed == count) {
        ways++;
        return;
      }
      if (diagonal > 2 * side - 2) return;
      if (2 * side - 1 - diagonal < count - placed) return;
      // Leave this diagonal empty.
      walk(diagonal + 1, placed);
      // Or set a bishop on one of its squares.
      for (var r = 0; r < side; r++) {
        final c = diagonal - r;
        if (c < 0 || c >= side) continue;
        final f = falling((r, c));
        if (fallingUsed.contains(f)) continue;
        fallingUsed.add(f);
        walk(diagonal + 1, placed + 1);
        fallingUsed.remove(f);
      }
    }

    walk(0, 0);
    return ways;
  }

  /// The most bishops that can stand: two less than twice the side,
  /// since the 2n - 1 rising diagonals hold one apiece at most and the
  /// two single-square ones, the corners, share a falling diagonal.
  int get most => 2 * side - 2;

  /// The two corner squares that hold the single-square rising
  /// diagonals, and whether they share a falling diagonal.
  (Square, Square) get lonelyCorners => ((0, 0), (side - 1, side - 1));

  bool get cornersShareFalling => falling((0, 0)) == falling((side - 1, side - 1));
}
