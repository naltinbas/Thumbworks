/// The law of the yard.
///
/// Every two birds have settled who pecks whom, one arrow a pair. A
/// king is a bird that reaches every other in one peck or two: it
/// pecks them, or pecks something that pecks them.
///
/// What a yard can crown is known more ways than one, and none of
/// them shares anything with the others. The biggest winner is
/// always a king, because whatever pecked it was pecked by
/// something it pecked; any king's peckers hide another king among
/// themselves; and the sweep flips through every yard there is and
/// counts the crowns, finding no yard of any size here that crowns
/// exactly two.
class Rules {
  /// The bird pairs of a yard, smaller bird first.
  static List<(int, int)> pairs(int birds) => [
        for (var one = 0; one < birds; one++)
          for (var two = one + 1; two < birds; two++) (one, two),
      ];

  /// Who pecks whom, from the arrows: bit set means the smaller
  /// bird of the pair pecks the larger.
  static List<List<bool>> pecks(int birds, int arrows) {
    final table = [
      for (var bird = 0; bird < birds; bird++)
        List<bool>.filled(birds, false),
    ];
    final all = pairs(birds);
    for (var at = 0; at < all.length; at++) {
      final (one, two) = all[at];
      if (arrows >> at & 1 == 1) {
        table[one][two] = true;
      } else {
        table[two][one] = true;
      }
    }
    return table;
  }

  /// The kings of a yard: every other bird within two pecks.
  static List<int> kings(int birds, int arrows) {
    final table = pecks(birds, arrows);
    final crowned = <int>[];
    for (var bird = 0; bird < birds; bird++) {
      var reign = true;
      for (var other = 0; other < birds && reign; other++) {
        if (other == bird || table[bird][other]) continue;
        var reached = false;
        for (var through = 0; through < birds; through++) {
          if (table[bird][through] && table[through][other]) {
            reached = true;
            break;
          }
        }
        if (!reached) reign = false;
      }
      if (reign) crowned.add(bird);
    }
    return crowned;
  }

  /// The bird with the most pecks won; ties to the earliest.
  static int biggestWinner(int birds, int arrows) {
    final table = pecks(birds, arrows);
    var best = 0;
    var bestWon = -1;
    for (var bird = 0; bird < birds; bird++) {
      final won = table[bird].where((pecked) => pecked).length;
      if (won > bestWon) {
        bestWon = won;
        best = bird;
      }
    }
    return best;
  }

  /// Fewest arrow flips from [arrows] until [goal] holds of the
  /// crowns, walking every flipping; -1 when no yard at all does.
  static int flipsTo(
      int birds, int arrows, bool Function(List<int>) goal) {
    if (goal(kings(birds, arrows))) return 0;
    final count = pairs(birds).length;
    final seen = <int>{arrows};
    var edge = [arrows];
    var flips = 0;
    while (edge.isNotEmpty) {
      flips++;
      final next = <int>[];
      for (final yard in edge) {
        for (var at = 0; at < count; at++) {
          final flipped = yard ^ (1 << at);
          if (!seen.add(flipped)) continue;
          if (goal(kings(birds, flipped))) return flips;
          next.add(flipped);
        }
      }
      edge = next;
    }
    return -1;
  }

  /// A flip that starts a shortest road to [goal]: the arrow's pair
  /// index, or null when the goal is met or beyond all flipping.
  static int? bestFlip(
      int birds, int arrows, bool Function(List<int>) goal) {
    final here = flipsTo(birds, arrows, goal);
    if (here <= 0) return null;
    final count = pairs(birds).length;
    for (var at = 0; at < count; at++) {
      if (flipsTo(birds, arrows ^ (1 << at), goal) == here - 1) {
        return at;
      }
    }
    return null;
  }

  /// How many yards of [birds] crown each count, over every yard.
  static Map<int, int> crownings(int birds) {
    final count = pairs(birds).length;
    final histogram = <int, int>{};
    for (var arrows = 0; arrows < (1 << count); arrows++) {
      final crowned = kings(birds, arrows).length;
      histogram[crowned] = (histogram[crowned] ?? 0) + 1;
    }
    return histogram;
  }
}
