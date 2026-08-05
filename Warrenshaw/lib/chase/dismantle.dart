import 'chart.dart';

/// Taking a map to pieces, one useless place at a time.
///
/// A place is **covered** by another when everywhere you could go from it,
/// you could also go from the other — its own place included. Standing on a
/// covered place is never worth anything to a runner: whatever it could do
/// from there, it could do from the place that covers it, and the seeker is
/// no further away. So a covered place can be rubbed off the map without
/// changing who wins.
///
/// Keep rubbing them off. If the map comes down to a single place, the seeker
/// wins; if it gets stuck with several places and none of them covered, the
/// runner gets away for ever.
///
/// That is a theorem — Quilliot, and Nowakowski and Winkler, in the early
/// eighties — and it is the reason this file is here rather than just the
/// table next door. The table settles a map by walking every position of the
/// chase. This settles it by rubbing out places. They have nothing in common
/// but the answer, and a test holds them against each other on every map that
/// ships and on a few hundred made up at random.
class Dismantle {
  const Dismantle._();

  /// Which place covers which, over the places still on the map.
  ///
  /// A place is covered by another if everywhere it reaches, the other
  /// reaches too. Being next to itself is part of that, so a place can only
  /// be covered by one of its own neighbours.
  static (int, int)? covered(Chart chart, Set<int> left) {
    for (final one in left) {
      for (final other in left) {
        if (one == other) continue;
        var all = true;
        for (final next in chart.beside[one]) {
          if (!left.contains(next)) continue;
          if (!chart.beside[other].contains(next)) {
            all = false;
            break;
          }
        }
        if (all) return (one, other);
      }
    }
    return null;
  }

  /// Rubs out covered places for as long as there are any, and says what was
  /// rubbed out, in order, and what was left.
  static (List<(int, int)>, Set<int>) apart(Chart chart) {
    final left = {for (var place = 0; place < chart.count; place++) place};
    final order = <(int, int)>[];

    while (left.length > 1) {
      final next = covered(chart, left);
      if (next == null) break;
      order.add(next);
      left.remove(next.$1);
    }
    return (order, left);
  }

  /// Whether the map comes apart altogether, which is the same thing as the
  /// seeker being able to win it.
  static bool comesApart(Chart chart) => apart(chart).$2.length == 1;
}
