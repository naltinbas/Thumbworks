import 'frac.dart';

/// Five greens with lanes laid between them. A stringing is a set of
/// lanes that joins every green with no loop in it, which takes four
/// lanes and no more. Every lane gets a share: the fraction of the
/// village's stringings that run along it.
///
/// However the lanes lie, the shares add to four. Ronald Foster proved
/// it in 1949 for electrical networks, where a lane's share is the
/// resistance the village offers between its two ends when every lane
/// is a one ohm wire, and the total comes to the number of greens less
/// one.
class Rules {
  static const greens = 5;

  /// Every pair of greens, in the order the board draws them.
  static const lanes = <(int, int)>[
    (1, 2), (1, 3), (1, 4), (1, 5),
    (2, 3), (2, 4), (2, 5),
    (3, 4), (3, 5),
    (4, 5),
  ];

  static int get howManyLanes => lanes.length;

  /// How many lanes a stringing takes.
  static int get inAStringing => greens - 1;

  /// The village a go opens on: four lanes into green 5, the smallest
  /// village that still joins every green.
  static int get opening => laid(const [3, 6, 8, 9]);

  static int laid(List<int> which) {
    var mask = 0;
    for (final lane in which) {
      mask |= 1 << lane;
    }
    return mask;
  }

  static bool has(int mask, int lane) => mask >> lane & 1 == 1;

  static int toggle(int mask, int lane) => mask ^ (1 << lane);

  static List<int> laidLanes(int mask) =>
      [for (var lane = 0; lane < lanes.length; lane++) if (has(mask, lane)) lane];

  static int howMany(int mask) => laidLanes(mask).length;

  /// Whether the lanes joins every green to every other.
  static bool joinedUp(int mask) {
    final reached = <int>{1};
    final queue = <int>[1];
    for (var head = 0; head < queue.length; head++) {
      for (var lane = 0; lane < lanes.length; lane++) {
        if (!has(mask, lane)) continue;
        final (a, b) = lanes[lane];
        final other = a == queue[head] ? b : (b == queue[head] ? a : 0);
        if (other != 0 && reached.add(other)) queue.add(other);
      }
    }
    return reached.length == greens;
  }

  /// Every stringing of the village: the sets of four lanes that join
  /// every green without a loop.
  static List<int> stringings(int mask) {
    final laid = laidLanes(mask);
    final out = <int>[];
    void pick(int from, int taken, int count) {
      if (count == inAStringing) {
        if (joinedUp(taken)) out.add(taken);
        return;
      }
      for (var i = from; i < laid.length; i++) {
        pick(i + 1, taken | (1 << laid[i]), count + 1);
      }
    }

    pick(0, 0, 0);
    return out;
  }

  /// The first voice: a lane's share is the fraction of the stringings
  /// that run along it, counted one by one.
  static Map<int, Frac> shares(int mask) {
    final all = stringings(mask);
    if (all.isEmpty) return const {};
    final out = <int, Frac>{};
    for (final lane in laidLanes(mask)) {
      var on = 0;
      for (final stringing in all) {
        if (has(stringing, lane)) on++;
      }
      out[lane] = Frac.of(on, all.length);
    }
    return out;
  }

  /// The second voice: put a unit of traffic in at one end of the lane
  /// and take it out at the other, let it spread over every lane at
  /// once, and read the difference between the two ends. This is the
  /// resistance of the village across that lane, worked in exact
  /// fractions and counting nothing.
  static Frac resistance(int mask, int lane) {
    final (from, to) = lanes[lane];
    final kept = [for (var g = 1; g <= greens; g++) if (g != to) g];
    final n = kept.length;
    final rows = [
      for (var r = 0; r < n; r++) [for (var c = 0; c <= n; c++) Frac.zero],
    ];
    for (final at in laidLanes(mask)) {
      final (a, b) = lanes[at];
      for (final (x, y) in [(a, b), (b, a)]) {
        final i = kept.indexOf(x);
        if (i < 0) continue;
        rows[i][i] = rows[i][i] + Frac.one;
        final j = kept.indexOf(y);
        if (j >= 0) rows[i][j] = rows[i][j] - Frac.one;
      }
    }
    rows[kept.indexOf(from)][n] = Frac.one;
    for (var c = 0; c < n; c++) {
      var pivot = c;
      while (pivot < n && rows[pivot][c] == Frac.zero) {
        pivot++;
      }
      if (pivot == n) continue;
      final swap = rows[c];
      rows[c] = rows[pivot];
      rows[pivot] = swap;
      final by = rows[c][c];
      for (var k = c; k <= n; k++) {
        rows[c][k] = rows[c][k] / by;
      }
      for (var r = 0; r < n; r++) {
        if (r == c || rows[r][c] == Frac.zero) continue;
        final f = rows[r][c];
        for (var k = c; k <= n; k++) {
          rows[r][k] = rows[r][k] - f * rows[c][k];
        }
      }
    }
    return rows[kept.indexOf(from)][n];
  }

  /// What the shares add to. It is always the greens less one.
  static Frac total(int mask) {
    var out = Frac.zero;
    for (final share in shares(mask).values) {
      out = out + share;
    }
    return out;
  }

  /// Every village that joins its greens up.
  static Iterable<int> villages() sync* {
    for (var mask = 0; mask < 1 << lanes.length; mask++) {
      if (joinedUp(mask)) yield mask;
    }
  }

  /// The taps it takes to lay and lift lanes from one village to
  /// another. Laying is always allowed and the lanes to be lifted can
  /// always be lifted last, so this is the count of lanes they differ
  /// by.
  static int taps(int from, int to) => howMany(from ^ to);

  static String tellLane(int lane) {
    final (a, b) = lanes[lane];
    return '$a to $b';
  }

  static String tellVillage(int mask) =>
      laidLanes(mask).map(tellLane).join(', ');
}
