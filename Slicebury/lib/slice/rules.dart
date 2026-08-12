/// The law of the cake.
///
/// Twelve candle spots stand round a convex rim. Candles at
/// some of them, a knife line between every pair, and the
/// slices counted. Up to five candles the count doubles: one,
/// two, four, eight, sixteen. Six candles never double again:
/// thirty-one at the most, since slices are one plus the lines
/// plus the crossings, lines are fifteen, and crossings pick
/// four candles apiece; and clumped crossings only lose, three
/// lines through one point paying two where three would.
class Rules {
  /// The rim spots, a convex twelve-ring on whole numbers.
  static const spots = [
    (4, 0), (3, 2), (2, 3), (0, 4), (-2, 3), (-3, 2),
    (-4, 0), (-3, -2), (-2, -3), (0, -4), (2, -3), (3, -2),
  ];

  /// The most candles any cake takes.
  static const mostCandles = 6;

  static int _cross((int, int) o, (int, int) a, (int, int) b) =>
      (a.$1 - o.$1) * (b.$2 - o.$2) -
      (a.$2 - o.$2) * (b.$1 - o.$1);

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Where two knife lines properly cross, as an exact point
  /// (xNum, yNum, den), or null: whole-number arithmetic all
  /// the way down.
  static (int, int, int)? meet(
      (int, int) a, (int, int) b, (int, int) c, (int, int) d) {
    final one = _cross(a, b, c);
    final two = _cross(a, b, d);
    final three = _cross(c, d, a);
    final four = _cross(c, d, b);
    if ((one > 0) == (two > 0) || (three > 0) == (four > 0)) {
      return null;
    }
    if (one == 0 || two == 0 || three == 0 || four == 0) {
      return null;
    }
    // a + t(b - a) with t = three / (three - four).
    final tNum = three;
    final tDen = three - four;
    var xNum = a.$1 * tDen + tNum * (b.$1 - a.$1);
    var yNum = a.$2 * tDen + tNum * (b.$2 - a.$2);
    var den = tDen;
    if (den < 0) {
      xNum = -xNum;
      yNum = -yNum;
      den = -den;
    }
    final shrink = _gcd(_gcd(xNum.abs(), yNum.abs()), den);
    return (xNum ~/ shrink, yNum ~/ shrink, den ~/ shrink);
  }

  /// The crossing points of a candle pick, each with how many
  /// knife lines run through it.
  static Map<(int, int, int), int> crossings(List<int> picked) {
    final pairsThrough = <(int, int, int), int>{};
    final lines = [
      for (var a = 0; a < picked.length; a++)
        for (var b = a + 1; b < picked.length; b++) (a, b),
    ];
    for (var one = 0; one < lines.length; one++) {
      for (var two = one + 1; two < lines.length; two++) {
        final (a, b) = lines[one];
        final (c, d) = lines[two];
        if (a == c || a == d || b == c || b == d) continue;
        final hit = meet(spots[picked[a]], spots[picked[b]],
            spots[picked[c]], spots[picked[d]]);
        if (hit == null) continue;
        pairsThrough[hit] = (pairsThrough[hit] ?? 0) + 1;
      }
    }
    // Pairs through a point tell the lines through it: k lines
    // meet in k(k-1)/2 pairs.
    final linesThrough = <(int, int, int), int>{};
    pairsThrough.forEach((hit, pairs) {
      var lines = 2;
      while (lines * (lines - 1) ~/ 2 < pairs) {
        lines++;
      }
      linesThrough[hit] = lines;
    });
    return linesThrough;
  }

  /// The slices, by Euler: spots plus crossings, less the
  /// edges, faces out of the leftovers, the outside dropped.
  static int slicesByEuler(List<int> picked) {
    final n = picked.length;
    if (n == 0) return 1;
    final through = crossings(picked);
    final vertices = n + through.length;
    // Each knife line is cut by the crossings on it; count
    // them line by line.
    var lineEdges = 0;
    for (var a = 0; a < n; a++) {
      for (var b = a + 1; b < n; b++) {
        var cuts = 0;
        through.forEach((hit, _) {
          final (xNum, yNum, den) = hit;
          final from = spots[picked[a]];
          final to = spots[picked[b]];
          final onLine = (to.$1 - from.$1) * (yNum - from.$2 * den) ==
              (to.$2 - from.$2) * (xNum - from.$1 * den);
          if (!onLine) return;
          final within = (xNum - from.$1 * den) *
                      (xNum - to.$1 * den) +
                  (yNum - from.$2 * den) * (yNum - to.$2 * den) <
              0;
          if (within) cuts++;
        });
        lineEdges += cuts + 1;
      }
    }
    final rimEdges = n == 1 ? 1 : n;
    final edges = lineEdges + rimEdges;
    if (n == 1) return 1;
    if (n == 2) return 2;
    final faces = 2 - vertices + edges;
    return faces - 1;
  }

  /// The slices a second way: one, plus a slice per knife
  /// line, plus a slice per crossing, clumped crossings paying
  /// their lines less one.
  static int slicesByCuts(List<int> picked) {
    final n = picked.length;
    var slices = 1 + n * (n - 1) ~/ 2;
    crossings(picked).forEach((_, lines) {
      slices += lines - 1;
    });
    return slices;
  }

  /// The general-position formula: one plus the pairs plus the
  /// fours. Speaks only when no crossing clumps.
  static int byFormula(int candles) {
    int choose(int n, int k) {
      var top = 1, bottom = 1;
      for (var at = 0; at < k; at++) {
        top *= n - at;
        bottom *= at + 1;
      }
      return top ~/ bottom;
    }

    return 1 + choose(candles, 2) + choose(candles, 4);
  }

  /// Every pick of [candles] spots, walked; calls [visit].
  static void picks(int candles, void Function(List<int>) visit) {
    final picked = <int>[];
    void grow(int from) {
      if (picked.length == candles) {
        visit(picked);
        return;
      }
      for (var spot = from; spot < spots.length; spot++) {
        picked.add(spot);
        grow(spot + 1);
        picked.removeLast();
      }
    }

    grow(0);
  }

  /// How many picks of [candles] make exactly [slices].
  static int waysTo(int candles, int slices) {
    var ways = 0;
    picks(candles, (picked) {
      if (slicesByEuler(picked) == slices) ways++;
    });
    return ways;
  }

  /// The two counts held together over every pick up to the
  /// candle cap, and the formula where nothing clumps: true
  /// when nothing breaks.
  static bool lawsHold() {
    var sound = true;
    for (var candles = 1; candles <= mostCandles; candles++) {
      picks(candles, (picked) {
        final euler = slicesByEuler(picked);
        final cuts = slicesByCuts(picked);
        if (euler != cuts) sound = false;
        final clumped = crossings(picked)
            .values
            .any((lines) => lines > 2);
        if (!clumped && euler != byFormula(candles)) {
          sound = false;
        }
        if (candles == 6 && euler > 31) sound = false;
      });
    }
    return sound;
  }
}
