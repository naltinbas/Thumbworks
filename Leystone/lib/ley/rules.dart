/// The law of the leys.
///
/// A green is a square of berths, and stones stand on berths. Three
/// stones ley when one straight line passes through all three, on
/// any slope there is: rows and columns, diagonals, and every
/// knight's-slant between. A ring of stones is sound while no three
/// of them ley.
///
/// How many stones a green can hold is known two ways that share
/// nothing. The search raises every ring there is and keeps the
/// fullest; plain counting says a green of n rows holds at most two
/// stones a row, so 2n is the roof and the odd stone past it must
/// ley. The suite proves the counting against the search on every
/// green that ships.
class Rules {
  /// Whether three berths share one straight line.
  static bool ley((int, int) a, (int, int) b, (int, int) c) =>
      (b.$1 - a.$1) * (c.$2 - a.$2) ==
      (b.$2 - a.$2) * (c.$1 - a.$1);

  /// The pair of standing stones a newcomer would ley with, or null.
  static ((int, int), (int, int))? leysWith(
      List<(int, int)> stones, (int, int) berth) {
    for (var one = 0; one < stones.length; one++) {
      for (var two = one + 1; two < stones.length; two++) {
        if (ley(stones[one], stones[two], berth)) {
          return (stones[one], stones[two]);
        }
      }
    }
    return null;
  }

  /// Whether a whole ring is sound: no three stones ley.
  static bool sound(List<(int, int)> stones) {
    for (var one = 0; one < stones.length; one++) {
      for (var two = one + 1; two < stones.length; two++) {
        for (var three = two + 1; three < stones.length; three++) {
          if (ley(stones[one], stones[two], stones[three])) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// The fullest ring the green holds and how many rings reach it,
  /// found by raising every sound ring. Returns (most, ways).
  static (int, int) fullest(int size) {
    final berths = _berths(size);
    var most = 0;
    var ways = 0;
    final ring = <(int, int)>[];

    void grow(int from) {
      if (ring.length > most) {
        most = ring.length;
        ways = 1;
      } else if (ring.length == most && most > 0) {
        ways++;
      }
      for (var at = from; at < berths.length; at++) {
        if (ring.length + (berths.length - at) < most) break;
        if (leysWith(ring, berths[at]) != null) continue;
        ring.add(berths[at]);
        grow(at + 1);
        ring.removeLast();
      }
    }

    grow(0);
    return (most, ways);
  }

  /// A sound ring of [asked] stones growing from the standing ones,
  /// searched over every raising; null when none exists.
  static List<(int, int)>? complete(
      int size, List<(int, int)> stones, int asked) {
    if (!sound(stones)) return null;
    final berths = _berths(size);
    final ring = List.of(stones);

    List<(int, int)>? grow(int from) {
      if (ring.length == asked) return List.of(ring);
      for (var at = from; at < berths.length; at++) {
        if (ring.length + (berths.length - at) < asked) break;
        if (ring.contains(berths[at])) continue;
        if (leysWith(ring, berths[at]) != null) continue;
        ring.add(berths[at]);
        final found = grow(at + 1);
        ring.removeLast();
        if (found != null) return found;
      }
      return null;
    }

    // Standing stones need not come first in berth order, so the
    // search may take any free berth from the top.
    return grow(0);
  }

  /// The counting that bars the odd stone: lay out any [asked]
  /// berths on a green of [size] rows and some row holds three.
  /// True when every single laying-out fails; only for greens small
  /// enough to try them all.
  static bool oddStoneAlwaysLeys(int size, int asked) {
    final berths = _berths(size);
    final chosen = <(int, int)>[];

    bool everyLayingLeys(int from) {
      if (chosen.length == asked) {
        final rows = List<int>.filled(size, 0);
        for (final (_, y) in chosen) {
          rows[y]++;
        }
        // Three in a row is a ley: the row itself is the line.
        return rows.any((held) => held >= 3);
      }
      for (var at = from; at < berths.length; at++) {
        if (chosen.length + (berths.length - at) < asked) {
          return true;
        }
        chosen.add(berths[at]);
        final leys = everyLayingLeys(at + 1);
        chosen.removeLast();
        if (!leys) return false;
      }
      return true;
    }

    return everyLayingLeys(0);
  }

  static List<(int, int)> _berths(int size) => [
        for (var x = 0; x < size; x++)
          for (var y = 0; y < size; y++) (x, y),
      ];
}
