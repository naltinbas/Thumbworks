/// The wood: six hollows, and birds tethered between two of them.
///
/// A bird sits in one of its two hollows and nowhere else. A seating is
/// a reading of which end each bird is at, so a wood of n birds has 2^n
/// of them, and the ask is always the same: no two birds in one hollow.
///
/// Everything here is whole numbers. There is no rounding anywhere in
/// this file and no number that is not counted.
class Rules {
  /// The hollows in the bank, lettered A to F.
  static const hollows = 6;

  static String letter(int hollow) => String.fromCharCode(65 + hollow);

  /// Every tether the wood allows: the 15 pairs of hollows, low end
  /// first.
  static List<(int, int)> get tethers => [
        for (var a = 0; a < hollows; a++)
          for (var b = a + 1; b < hollows; b++) (a, b),
      ];

  /// Reads a board off its letters: 'ABAC' is two birds, one tethered
  /// between A and B and one between A and C.
  static List<(int, int)> read(String board) => [
        for (var i = 0; i < board.length; i += 2)
          (
            board.codeUnitAt(i) - 65,
            board.codeUnitAt(i + 1) - 65,
          ),
      ];

  static String write(List<(int, int)> birds) =>
      birds.map((b) => '${letter(b.$1)}${letter(b.$2)}').join(' ');

  /// Where each bird sits under seating [pick]: bit i says which end of
  /// bird i's tether it is at, 0 for the low-lettered hollow.
  static List<int> seats(List<(int, int)> birds, int pick) => [
        for (var i = 0; i < birds.length; i++)
          (pick >> i) & 1 == 0 ? birds[i].$1 : birds[i].$2,
      ];

  /// The hollow bird [i] would fly to if it were tapped.
  static int across(List<(int, int)> birds, int pick, int i) =>
      (pick >> i) & 1 == 0 ? birds[i].$2 : birds[i].$1;

  /// The birds in each hollow under [pick], in order.
  static List<List<int>> crowds(List<(int, int)> birds, int pick) {
    final by = List.generate(hollows, (_) => <int>[]);
    final at = seats(birds, pick);
    for (var i = 0; i < birds.length; i++) {
      by[at[i]].add(i);
    }
    return by;
  }

  /// Whether every bird has a hollow to itself.
  static bool settled(List<(int, int)> birds, int pick) {
    var used = 0;
    for (final hollow in seats(birds, pick)) {
      final bit = 1 << hollow;
      if (used & bit != 0) return false;
      used |= bit;
    }
    return true;
  }

  /// The first voice. Walks all 2^n seatings and counts the ones that
  /// settle. It knows nothing about patches and asks no questions about
  /// the shape of the wood.
  static int tally(List<(int, int)> birds) {
    var ways = 0;
    for (var pick = 0; pick < 1 << birds.length; pick++) {
      if (settled(birds, pick)) ways++;
    }
    return ways;
  }

  /// Which patch each hollow belongs to, patches numbered from 0. A
  /// patch is a set of hollows joined up by tethers, and a patch with
  /// more birds than hollows is the whole of the theorem: the wood
  /// settles exactly when no patch has one.
  static List<int> patchOf(List<(int, int)> birds) {
    final up = [for (var h = 0; h < hollows; h++) h];
    int root(int x) {
      while (up[x] != x) {
        up[x] = up[up[x]];
        x = up[x];
      }
      return x;
    }

    for (final bird in birds) {
      final a = root(bird.$1), b = root(bird.$2);
      if (a != b) up[a] = b;
    }
    final number = <int, int>{};
    return [
      for (var h = 0; h < hollows; h++)
        number.putIfAbsent(root(h), () => number.length),
    ];
  }

  /// Hollows and birds in each patch, patch by patch.
  static List<(int, int)> patchSizes(List<(int, int)> birds) {
    final of = patchOf(birds);
    final count = of.isEmpty ? 0 : of.reduce((a, b) => a > b ? a : b) + 1;
    final holes = List.filled(count, 0), wings = List.filled(count, 0);
    for (var h = 0; h < hollows; h++) {
      holes[of[h]]++;
    }
    for (final bird in birds) {
      wings[of[bird.$1]]++;
    }
    return [for (var p = 0; p < count; p++) (holes[p], wings[p])];
  }

  /// The second voice. Reads the answer off the shape of the wood
  /// without ever writing a seating down.
  ///
  /// A patch whose birds outnumber its hollows settles no way at all. A
  /// patch of v hollows strung with v-1 birds is a thicket, and it
  /// settles v ways, one for each hollow it leaves empty. A patch of v
  /// hollows strung with v birds carries one ring, and it settles two
  /// ways, the ring turning one way or the other. The wood's count is
  /// the patches multiplied together.
  static int census(List<(int, int)> birds) {
    var ways = 1;
    for (final patch in patchSizes(birds)) {
      final (holes, wings) = patch;
      if (wings > holes) return 0;
      if (wings == 0) continue;
      ways *= wings == holes ? 2 : holes;
    }
    return ways;
  }

  /// The third voice. Takes every one of the 64 sets of hollows in turn
  /// and counts the birds with both ends inside it. Returns the first
  /// set that holds more birds than hollows, as a bitmask, or null when
  /// none does. This is Hall's condition written out for birds that
  /// have two hollows apiece.
  static int? overfull(List<(int, int)> birds) {
    for (var set = 1; set < 1 << hollows; set++) {
      var holes = 0, wings = 0;
      for (var h = 0; h < hollows; h++) {
        if (set >> h & 1 == 1) holes++;
      }
      for (final bird in birds) {
        if (set >> bird.$1 & 1 == 1 && set >> bird.$2 & 1 == 1) wings++;
      }
      if (wings > holes) return set;
    }
    return null;
  }

  /// The fourth voice. Walks the birds one at a time, sending each to a
  /// free hollow or shoving the sitting bird along to make room, which
  /// is the augmenting path the player walks by thumb. Returns a
  /// seating, or null when some bird has nowhere to go.
  static int? found(List<(int, int)> birds) {
    final sitting = List.filled(hollows, -1);
    bool shove(int bird, Set<int> tried) {
      for (final hollow in [birds[bird].$1, birds[bird].$2]) {
        if (!tried.add(hollow)) continue;
        if (sitting[hollow] < 0 || shove(sitting[hollow], tried)) {
          sitting[hollow] = bird;
          return true;
        }
      }
      return false;
    }

    for (var i = 0; i < birds.length; i++) {
      if (!shove(i, <int>{})) return null;
    }
    var pick = 0;
    for (var h = 0; h < hollows; h++) {
      final bird = sitting[h];
      if (bird >= 0 && birds[bird].$2 == h) pick |= 1 << bird;
    }
    return pick;
  }

  /// Every seating that settles the wood.
  static List<int> landings(List<(int, int)> birds) => [
        for (var pick = 0; pick < 1 << birds.length; pick++)
          if (settled(birds, pick)) pick,
      ];

  /// The taps between two seatings, which is one for each bird that has
  /// to cross.
  static int between(int from, int to) {
    var n = 0, bits = from ^ to;
    while (bits != 0) {
      n += bits & 1;
      bits >>= 1;
    }
    return n;
  }

  /// The nearest seating that settles the wood, and the taps to it.
  static (int, int)? nearest(List<(int, int)> birds, int pick) {
    int? best;
    var away = -1;
    for (final landing in landings(birds)) {
      final n = between(pick, landing);
      if (away < 0 || n < away) {
        away = n;
        best = landing;
      }
    }
    return best == null ? null : (best, away);
  }

  /// The opening: every bird at the low-lettered end of its tether. The
  /// checker holds every board to it, and it settles none of them.
  static const opening = 0;
}
