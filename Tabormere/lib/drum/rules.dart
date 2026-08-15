/// The arithmetic of the rhythm: a ring of steps, some of them hits, and
/// how evenly the hits are spread. A rhythm is even when, for every
/// count of hits in a row, the spans those hits cover come to at most
/// two lengths, a step apart: the gaps between neighbours all alike or
/// of two kinds a step apart, the spans of two gaps likewise, and so on
/// round. Two voices: the sweep, every pattern of the hits tried against
/// that; and Euclid's rule, the hits set at the floors of i n/k, which
/// lays one even rhythm down with no sweep, and whose turnings are all
/// the even rhythms there are.
class Rules {
  /// Every pattern of [hits] hits on [steps] steps, as sorted step
  /// lists, in order.
  static List<List<int>> patterns(int steps, int hits) {
    final out = <List<int>>[];
    final pick = <int>[];
    void go(int from) {
      if (pick.length == hits) {
        out.add(List.of(pick));
        return;
      }
      for (var s = from; s <= steps - (hits - pick.length); s++) {
        pick.add(s);
        go(s + 1);
        pick.removeLast();
      }
    }

    go(0);
    return out;
  }

  /// The gaps between neighbouring hits, round the ring, from each hit
  /// to the next.
  static List<int> gaps(int steps, List<int> hitsAt) => [
        for (var i = 0; i < hitsAt.length; i++) (hitsAt[(i + 1) % hitsAt.length] - hitsAt[i] + steps) % steps == 0 && hitsAt.length == 1 ? steps : (hitsAt[(i + 1) % hitsAt.length] - hitsAt[i] + steps) % steps,
      ];

  /// Whether the pattern is even: for every span of j gaps in a row, j
  /// from 1 to one less than the hits, the k sums round the ring take at
  /// most two values, and those a step apart. One hit or none is even.
  static bool isEven(int steps, List<int> hitsAt) {
    final k = hitsAt.length;
    if (k <= 1) return true;
    final g = gaps(steps, hitsAt);
    for (var j = 1; j < k; j++) {
      final sums = <int>{};
      for (var i = 0; i < k; i++) {
        var s = 0;
        for (var t = 0; t < j; t++) {
          s += g[(i + t) % k];
        }
        sums.add(s);
      }
      if (sums.length > 2) return false;
      if (sums.length == 2 && (sums.reduce((a, b) => a > b ? a : b) - sums.reduce((a, b) => a < b ? a : b)) != 1) return false;
    }
    return true;
  }

  /// Euclid's rhythm: hit i at the floor of i steps over hits.
  static List<int> euclid(int steps, int hits) => [for (var i = 0; i < hits; i++) i * steps ~/ hits];

  /// The pattern turned [by] steps round the ring, sorted.
  static List<int> turned(int steps, List<int> hitsAt, int by) => [for (final h in hitsAt) (h + by) % steps]..sort();

  /// All the distinct turnings of a pattern, as sorted lists, in order
  /// of the turn.
  static List<List<int>> turnings(int steps, List<int> hitsAt) {
    final seen = <String>{};
    final out = <List<int>>[];
    for (var by = 0; by < steps; by++) {
      final t = turned(steps, hitsAt, by);
      if (seen.add(t.join(','))) out.add(t);
    }
    return out;
  }

  /// The even patterns of the sweep, and the turnings of Euclid's rhythm,
  /// both as sets of keys, for the checker to hold together.
  static Set<String> evenBySweep(int steps, int hits) => {
        for (final p in patterns(steps, hits))
          if (isEven(steps, p)) p.join(','),
      };

  static Set<String> evenByEuclid(int steps, int hits) => {
        for (final t in turnings(steps, euclid(steps, hits))) t.join(','),
      };

  /// Whether every gap of the pattern is the same.
  static bool equalGaps(int steps, List<int> hitsAt) => gaps(steps, hitsAt).toSet().length <= 1;

  /// A pattern told: 'x..x..x.'.
  static String told(int steps, List<int> hitsAt) => [for (var s = 0; s < steps; s++) hitsAt.contains(s) ? 'x' : '.'].join();

  static int choose(int n, int k) {
    var c = 1;
    for (var i = 0; i < k; i++) {
      c = c * (n - i) ~/ (i + 1);
    }
    return c;
  }
}
