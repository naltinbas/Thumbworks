/// The law of the bench.
///
/// Marrows come up one at a time, and a judge sees only how each
/// stands against the ones already seen. Take one and the sitting
/// ends; wave it by and it is gone for good. The last must be taken.
/// The sitting is won when the marrow taken turns out the best of
/// the whole bench.
///
/// What a judge can do is known two ways that share nothing: the
/// wave-them-by rule, which lets a fixed count pass and then takes
/// the first best-yet; and the sweep, which plays every rank-based
/// rule there is against every sitting of the bench and counts.
/// Where the sweep can hold every rule, the rule's count is the
/// ceiling itself.
class Rules {
  /// Whether the rule takes now: past the waved-by count and looking
  /// at a best-yet, or out of bench.
  static bool takes(int skip, int step, bool record, int marrows) {
    if (step >= marrows) return true;
    return step > skip && record;
  }

  /// Every ordering of a bench: which true size stands at each seat.
  static List<List<int>> allSittings(int marrows) {
    final sittings = <List<int>>[];
    final sitting = <int>[];
    final used = List<bool>.filled(marrows, false);

    void grow() {
      if (sitting.length == marrows) {
        sittings.add(List.of(sitting));
        return;
      }
      for (var size = 0; size < marrows; size++) {
        if (used[size]) continue;
        used[size] = true;
        sitting.add(size);
        grow();
        sitting.removeLast();
        used[size] = false;
      }
    }

    grow();
    return sittings;
  }

  /// Sittings the wave-them-by rule wins, over all of them.
  static int winsOfCutoff(int marrows, int skip) {
    var wins = 0;
    for (final sitting in allSittings(marrows)) {
      if (_cutoffTakes(sitting, skip) == marrows - 1) wins++;
    }
    return wins;
  }

  /// The size the rule takes on one sitting.
  static int _cutoffTakes(List<int> sitting, int skip) {
    var best = -1;
    for (var at = 0; at < sitting.length; at++) {
      final record = sitting[at] > best;
      if (record) best = sitting[at];
      if (takes(skip, at + 1, record, sitting.length)) {
        return sitting[at];
      }
    }
    return sitting.last;
  }

  /// The waved-by count that wins most sittings.
  static int bestSkip(int marrows) {
    var best = 0;
    var bestWins = -1;
    for (var skip = 0; skip < marrows; skip++) {
      final wins = winsOfCutoff(marrows, skip);
      if (wins > bestWins) {
        bestWins = wins;
        best = skip;
      }
    }
    return best;
  }

  /// The most sittings any rank-based rule wins: every rule swept
  /// against every sitting. A rule decides take-or-wave from the
  /// step and how the marrow ranks among the seen; the last is
  /// always taken. Only for benches short enough to hold them all.
  static int ceiling(int marrows) {
    final steps = marrows - 1;
    final choices = steps * (steps + 1) ~/ 2;
    final sittings = allSittings(marrows);
    var best = 0;
    for (var rule = 0; rule < (1 << choices); rule++) {
      var wins = 0;
      for (final sitting in sittings) {
        var taken = -1;
        for (var at = 0; at < marrows; at++) {
          if (at == marrows - 1) {
            taken = sitting[at];
            break;
          }
          var rank = 1;
          for (var seen = 0; seen < at; seen++) {
            if (sitting[seen] > sitting[at]) rank++;
          }
          final choice = at * (at + 1) ~/ 2 + rank - 1;
          if (rule & (1 << choice) != 0) {
            taken = sitting[at];
            break;
          }
        }
        if (taken == marrows - 1) wins++;
      }
      if (wins > best) best = wins;
    }
    return best;
  }

  /// How many rank-based rules a bench of [marrows] has.
  static int rulesOf(int marrows) {
    final steps = marrows - 1;
    return 1 << (steps * (steps + 1) ~/ 2);
  }

  static int factorial(int n) => n <= 1 ? 1 : n * factorial(n - 1);
}
