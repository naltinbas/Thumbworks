/// The law of the field.
///
/// Stones sit on the crossings of a five-by-five field. A chain is
/// the line the surveyor strings through every stone that shares
/// it: two stones at least, as many as lie in the row. A chain
/// holding exactly two stones is bare; one holding three or more
/// is laden.
///
/// The old law is Sylvester and Gallai's: stones not all in one
/// row always show a bare chain. The sweep lays every placing of
/// three, four and five stones on the field, all 68,080 of them,
/// and not one stands against it. The counting is done twice, by
/// strung lines and by thirds-on-the-pair, and the suite refuses
/// the bake the moment the two part ways.
class Rules {
  static const side = 5;

  /// Every crossing of the field.
  static List<(int, int)> get field => [
        for (var x = 0; x < side; x++)
          for (var y = 0; y < side; y++) (x, y),
      ];

  /// The chains: every maximal strung line through two stones or
  /// more, found by grouping pairs onto exact rational lines.
  static List<List<(int, int)>> chains(List<(int, int)> stones) {
    final lines = <String, Set<(int, int)>>{};
    for (var a = 0; a < stones.length; a++) {
      for (var b = a + 1; b < stones.length; b++) {
        final (x1, y1) = stones[a];
        final (x2, y2) = stones[b];
        final String key;
        if (x1 == x2) {
          key = 'v$x1';
        } else {
          // Slope and intercept as reduced fractions.
          final dy = y2 - y1;
          final dx = x2 - x1;
          final g = _gcd(dy.abs(), dx.abs());
          final sm = dx < 0 ? -1 : 1;
          final mNum = dy * sm ~/ (g == 0 ? 1 : g);
          final mDen = dx * sm ~/ (g == 0 ? 1 : g);
          // c = y1 - m x1, as a fraction over mDen.
          final cNum = y1 * mDen - mNum * x1;
          final cg = _gcd(cNum.abs(), mDen);
          key = 's $mNum/$mDen '
              '${cNum ~/ (cg == 0 ? 1 : cg)}/${mDen ~/ (cg == 0 ? 1 : cg)}';
        }
        (lines[key] ??= {}).addAll([stones[a], stones[b]]);
      }
    }
    return [for (final strung in lines.values) strung.toList()];
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// How many chains are bare, by the strung lines.
  static int bareByChains(List<(int, int)> stones) =>
      chains(stones).where((chain) => chain.length == 2).length;

  /// How many chains are bare, counted the other way: a pair is
  /// bare when no third stone sits on its line, by cross product
  /// alone, and each bare pair is its own chain.
  static int bareByThirds(List<(int, int)> stones) {
    var bare = 0;
    for (var a = 0; a < stones.length; a++) {
      for (var b = a + 1; b < stones.length; b++) {
        final (x1, y1) = stones[a];
        final (x2, y2) = stones[b];
        var thirds = 0;
        for (var c = 0; c < stones.length; c++) {
          if (c == a || c == b) continue;
          final (x3, y3) = stones[c];
          if ((x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1) == 0) {
            thirds++;
          }
        }
        if (thirds == 0) bare++;
      }
    }
    return bare;
  }

  /// Whether every stone shares one row.
  static bool allInOneRow(List<(int, int)> stones) {
    if (stones.length < 3) return true;
    final strung = chains(stones);
    return strung.length == 1 &&
        strung.first.length == stones.length;
  }

  /// Every placing of [count] stones on the field, walked; calls
  /// [visit] with each. The sweep the checker and the suite share.
  static void placings(
      int count, void Function(List<(int, int)>) visit) {
    final spots = field;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < spots.length; at++) {
        picked.add(spots[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many placings of [count] stones show exactly [bare] bare
  /// chains; all-in-one-row placings kept or dropped by [inRow].
  static int waysTo(int count, int bare, {bool? inRow}) {
    var ways = 0;
    placings(count, (stones) {
      if (inRow != null && allInOneRow(stones) != inRow) return;
      if (bareByChains(stones) == bare) ways++;
    });
    return ways;
  }

  /// The two counts held together over every placing of [count]
  /// stones, and Sylvester and Gallai held to on each: true when
  /// nothing breaks.
  static bool lawHolds(int count) {
    var sound = true;
    placings(count, (stones) {
      final strung = bareByChains(stones);
      if (strung != bareByThirds(stones)) sound = false;
      if (!allInOneRow(stones) && strung == 0) sound = false;
    });
    return sound;
  }
}
