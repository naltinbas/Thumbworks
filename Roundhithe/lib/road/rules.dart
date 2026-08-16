/// Six villages, the fifteen roads that could join them, and the round
/// trip: a road-plan is a set of roads, told as a mask of fifteen bits,
/// and Dirac showed in 1952 that when every village has three roads or
/// more, half the others at least, a round trip through all six is
/// there.
class Rules {
  static const villages = 6;

  static const names = ['A', 'B', 'C', 'D', 'E', 'F'];

  /// The roads that could be, each a pair of villages, the lower first.
  static const pairs = <(int, int)>[
    (0, 1), (0, 2), (0, 3), (0, 4), (0, 5),
    (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 3), (2, 4), (2, 5),
    (3, 4), (3, 5),
    (4, 5),
  ];

  static int get roadsPossible => pairs.length;

  /// Every road-plan, as a mask.
  static int get plans => 1 << pairs.length;

  /// Which bit the road between [a] and [b] is.
  static int roadOf(int a, int b) {
    final lo = a < b ? a : b, hi = a < b ? b : a;
    for (var i = 0; i < pairs.length; i++) {
      if (pairs[i] == (lo, hi)) return i;
    }
    return -1;
  }

  static bool joined(int mask, int a, int b) => a != b && mask & (1 << roadOf(a, b)) != 0;

  static int toggled(int mask, int a, int b) => mask ^ (1 << roadOf(a, b));

  /// How many roads a plan has.
  static int roads(int mask) {
    var n = 0;
    for (var i = 0; i < pairs.length; i++) {
      if (mask & (1 << i) != 0) n++;
    }
    return n;
  }

  /// The roads of a plan, as pairs.
  static List<(int, int)> roadsOf(int mask) => [for (var i = 0; i < pairs.length; i++) if (mask & (1 << i) != 0) pairs[i]];

  /// How many roads leave village [v].
  static int degree(int mask, int v) {
    var n = 0;
    for (var u = 0; u < villages; u++) {
      if (u != v && joined(mask, u, v)) n++;
    }
    return n;
  }

  static List<int> degrees(int mask) => [for (var v = 0; v < villages; v++) degree(mask, v)];

  static int minDegree(int mask) => degrees(mask).reduce((a, b) => a < b ? a : b);

  /// Dirac's condition: every village has half the others at least.
  static bool dirac(int mask) => minDegree(mask) >= villages ~/ 2;

  /// Ore's condition: every two villages not joined have six roads
  /// between them at least.
  static bool ore(int mask) {
    for (final (a, b) in pairs) {
      if (!joined(mask, a, b) && degree(mask, a) + degree(mask, b) < villages) return false;
    }
    return true;
  }

  /// A round trip through all six villages, found by walking: every
  /// order of the other five from village A tried, the first that
  /// closes returned as the villages in order; null when none closes.
  /// The first voice.
  static List<int>? tripByWalk(int mask) {
    final order = [0];
    final used = List<bool>.filled(villages, false)..[0] = true;
    List<int>? go() {
      if (order.length == villages) {
        return joined(mask, order.last, 0) ? List.of(order) : null;
      }
      for (var v = 1; v < villages; v++) {
        if (used[v] || !joined(mask, order.last, v)) continue;
        used[v] = true;
        order.add(v);
        final found = go();
        if (found != null) return found;
        order.removeLast();
        used[v] = false;
      }
      return null;
    }

    return go();
  }

  /// Whether a round trip is there, by the table: for every set of
  /// villages holding A and every village in it, whether a path from A
  /// through exactly that set ends there; the trip closes when the
  /// full set ends next to A. The second voice.
  static bool tripByTable(int mask) {
    final full = (1 << villages) - 1;
    // reach[set] holds a bit for each village a path from A through set
    // can end at.
    final reach = List<int>.filled(1 << villages, 0);
    reach[1] = 1;
    for (var set = 1; set <= full; set++) {
      if (set & 1 == 0 || reach[set] == 0) continue;
      for (var v = 0; v < villages; v++) {
        if (reach[set] & (1 << v) == 0) continue;
        for (var u = 1; u < villages; u++) {
          if (set & (1 << u) != 0 || !joined(mask, v, u)) continue;
          reach[set | (1 << u)] |= 1 << u;
        }
      }
    }
    for (var v = 1; v < villages; v++) {
      if (reach[full] & (1 << v) != 0 && joined(mask, v, 0)) return true;
    }
    return false;
  }

  /// A plan told as its roads: 'AB, AC, BC'.
  static String tell(int mask) => roadsOf(mask).map((r) => '${names[r.$1]}${names[r.$2]}').join(', ');

  /// A mask from roads told as 'AB, AC'.
  static int planOf(String roads) {
    var mask = 0;
    for (final r in roads.split(',')) {
      final t = r.trim();
      if (t.isEmpty) continue;
      mask |= 1 << roadOf(names.indexOf(t[0]), names.indexOf(t[1]));
    }
    return mask;
  }
}
