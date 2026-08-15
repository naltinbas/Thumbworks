/// The law of the yard: for a side of n, one flag of one, two of two,
/// three of three and on to n of n, each k of them a k by k square, come
/// to 1 + 8 + 27 + ... + n cubed cells, and that is the square of
/// 1 + 2 + ... + n, which is Nicomachus's theorem; and they pave the
/// square yard of that side, the picture proof laying them in gnomons,
/// the L-shaped bands of width k round the corner, with the even k's
/// last flag cut in two halves, k by k/2, one at each end of its band.
///
/// So the flags of a yard are, for each k: k whole squares when k is
/// odd, and k - 1 whole squares and two halves when k is even. Every
/// paving is found by laying a flag at the first bare cell, top row
/// first, and found again column by column.
class Rules {
  /// A flag: width, height, and its size k, with a count.
  static List<(int, int, int, int)> flags(int n, {bool whole = false}) {
    final out = <(int, int, int, int)>[];
    for (var k = 1; k <= n; k++) {
      if (k.isOdd || whole) {
        out.add((k, k, k, k));
      } else {
        if (k - 1 > 0) out.add((k, k, k, k - 1));
        out.add((k, k ~/ 2, k, 2));
      }
    }
    return out;
  }

  /// The yard's side for [n]: the triangular number.
  static int side(int n) => n * (n + 1) ~/ 2;

  /// The sum of the cubes to [n].
  static int cubes(int n) {
    var sum = 0;
    for (var k = 1; k <= n; k++) {
      sum += k * k * k;
    }
    return sum;
  }

  /// Every paving of the [side] by [side] yard by [flags] (width, height,
  /// size, count), each half laid either way up: how many, and the
  /// first, as placements (kind index, width, height, x, y). [byColumns]
  /// reads column by column; [atMost] stops early.
  static (int, List<(int, int, int, int, int)>?) pavings(int side, List<(int, int, int, int)> flags, {bool byColumns = false, int? atMost}) {
    final grid = List.generate(side, (_) => List.filled(side, false));
    final counts = flags.map((f) => f.$4).toList();
    final placed = <(int, int, int, int, int)>[];
    var found = 0;
    List<(int, int, int, int, int)>? first;

    (int, int)? firstBare() {
      if (byColumns) {
        for (var x = 0; x < side; x++) {
          for (var y = 0; y < side; y++) {
            if (!grid[y][x]) return (x, y);
          }
        }
      } else {
        for (var y = 0; y < side; y++) {
          for (var x = 0; x < side; x++) {
            if (!grid[y][x]) return (x, y);
          }
        }
      }
      return null;
    }

    bool fits(int x, int y, int w, int h) {
      if (x + w > side || y + h > side) return false;
      for (var j = y; j < y + h; j++) {
        for (var i = x; i < x + w; i++) {
          if (grid[j][i]) return false;
        }
      }
      return true;
    }

    void set(int x, int y, int w, int h, bool v) {
      for (var j = y; j < y + h; j++) {
        for (var i = x; i < x + w; i++) {
          grid[j][i] = v;
        }
      }
    }

    void search() {
      if (atMost != null && found >= atMost) return;
      final bare = firstBare();
      if (bare == null) {
        found++;
        first ??= List.of(placed);
        return;
      }
      final (x, y) = bare;
      for (var i = 0; i < flags.length; i++) {
        if (counts[i] == 0) continue;
        final (w, h, _, _) = flags[i];
        final ways = w == h ? [(w, h)] : [(w, h), (h, w)];
        for (final (pw, ph) in ways) {
          if (!fits(x, y, pw, ph)) continue;
          counts[i]--;
          set(x, y, pw, ph, true);
          placed.add((i, pw, ph, x, y));
          search();
          placed.removeLast();
          set(x, y, pw, ph, false);
          counts[i]++;
        }
      }
    }

    search();
    return (found, first);
  }

  /// Nicomachus's own paving, gnomon by gnomon: band k runs along the
  /// bottom and the right of the (T_{k-1}) square already paved, its
  /// whole flags k apart along both arms and, for even k, a half at
  /// the end of each arm. Placements as (kind index into flags(n),
  /// width, height, x, y).
  static List<(int, int, int, int, int)> gnomons(int n) {
    final kinds = flags(n);
    final out = <(int, int, int, int, int)>[];
    for (var k = 1; k <= n; k++) {
      final inner = side(k - 1);
      final wholeKind = kinds.indexWhere((f) => f.$3 == k && f.$1 == k && f.$2 == k);
      final halfKind = kinds.indexWhere((f) => f.$3 == k && f.$2 == k ~/ 2 && f.$1 != f.$2);
      // The corner square of the band.
      out.add((wholeKind, k, k, inner, inner));
      if (k.isOdd) {
        // (k - 1) / 2 more along each arm.
        for (var m = 1; m <= (k - 1) ~/ 2; m++) {
          out.add((wholeKind, k, k, inner - m * k, inner));
          out.add((wholeKind, k, k, inner, inner - m * k));
        }
      } else {
        // k/2 - 1 more whole along each arm, then a half at the far end
        // of each: upright at the foot of the bottom arm, flat at the
        // top of the right arm.
        for (var m = 1; m <= k ~/ 2 - 1; m++) {
          out.add((wholeKind, k, k, inner - m * k, inner));
          out.add((wholeKind, k, k, inner, inner - m * k));
        }
        out.add((halfKind, k ~/ 2, k, 0, inner));
        out.add((halfKind, k, k ~/ 2, inner, 0));
      }
    }
    return out;
  }

  /// Whether [placements] pave the [side] square exactly: every cell
  /// once, nothing outside.
  static bool paves(int side, List<(int, int, int, int, int)> placements) {
    final grid = List.generate(side, (_) => List.filled(side, 0));
    for (final (_, w, h, x, y) in placements) {
      if (x < 0 || y < 0 || x + w > side || y + h > side) return false;
      for (var j = y; j < y + h; j++) {
        for (var i = x; i < x + w; i++) {
          grid[j][i]++;
        }
      }
    }
    return grid.every((row) => row.every((c) => c == 1));
  }
}
