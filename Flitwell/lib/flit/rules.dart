/// A lane of four cottages, a tenant in each, and every tenant with an
/// order they would rather live in.
///
/// A tenant owns the cottage they start in. Any group of them may swap
/// among themselves, but only among the cottages that group owns, which
/// is the whole point: nobody can be moved out by people who have
/// nothing to offer.
///
/// Everything here is whole numbers and comparisons of rank. There is
/// no arithmetic in this file beyond counting.
class Rules {
  static const cottages = 4;

  static String letter(int cottage) => String.fromCharCode(65 + cottage);

  /// Reads a street off its letters: 'BCAD BADC CABD ABCD' is four
  /// tenants, the first wanting B most and D least.
  static List<List<int>> read(String street) => [
        for (final word in street.split(' '))
          [for (var i = 0; i < word.length; i++) word.codeUnitAt(i) - 65],
      ];

  static String write(List<int> where) =>
      where.map(letter).join();

  /// Where tenant [t] puts [cottage] in their order, 0 being best.
  static int rank(List<List<int>> street, int t, int cottage) =>
      street[t].indexOf(cottage);

  /// Whether tenant [t] would rather have [a] than [b].
  static bool rather(List<List<int>> street, int t, int a, int b) =>
      rank(street, t, a) < rank(street, t, b);

  /// Every way of putting the four tenants in the four cottages, one
  /// each. There are 24, and the game walks all of them.
  static List<List<int>> allocations() {
    final all = <List<int>>[];
    void walk(List<int> so, List<bool> taken) {
      if (so.length == cottages) {
        all.add([...so]);
        return;
      }
      for (var c = 0; c < cottages; c++) {
        if (taken[c]) continue;
        taken[c] = true;
        walk([...so, c], taken);
        taken[c] = false;
      }
    }

    walk(const [], List.filled(cottages, false));
    return all;
  }

  /// Everyone in the cottage they own, which is where every ask opens.
  static List<int> get opening => [for (var t = 0; t < cottages; t++) t];

  /// The swaps between two lanes. Two tenants swapping cottages is one
  /// swap, so this is four less the number of rings in the shuffle from
  /// one to the other.
  static int between(List<int> from, List<int> to) {
    final step = List.filled(cottages, 0);
    for (var t = 0; t < cottages; t++) {
      // Which tenant ends up where this tenant started.
      step[from[t]] = to[t];
    }
    final seen = List.filled(cottages, false);
    var rings = 0;
    for (var c = 0; c < cottages; c++) {
      if (seen[c]) continue;
      rings++;
      var at = c;
      while (!seen[at]) {
        seen[at] = true;
        at = step[at];
      }
    }
    return cottages - rings;
  }

  /// Whether some group of tenants could walk out and do better among
  /// the cottages they own between them.
  ///
  /// With [firmly] set, a group only has to leave nobody worse off and
  /// make somebody better; without it, every one of them has to gain.
  /// The first is the harder test to pass, and the lane that passes it
  /// is the one this game is about.
  static List<int>? blockers(List<List<int>> street, List<int> where,
      {required bool firmly}) {
    for (var set = 1; set < 1 << cottages; set++) {
      final group = [
        for (var t = 0; t < cottages; t++)
          if (set >> t & 1 == 1) t,
      ];
      // The cottages the group owns are the ones its members started in.
      final ours = [...group];
      bool tryOut(List<int> deal, List<int> left) {
        if (deal.length == group.length) {
          if (!firmly) {
            // Every one of them has to gain.
            for (var k = 0; k < group.length; k++) {
              final t = group[k];
              if (!rather(street, t, deal[k], where[t])) return false;
            }
            return true;
          }
          // Nobody set back, and somebody better off.
          var gained = false;
          for (var k = 0; k < group.length; k++) {
            final t = group[k];
            if (rather(street, t, where[t], deal[k])) return false;
            if (rather(street, t, deal[k], where[t])) gained = true;
          }
          return gained;
        }
        for (var i = 0; i < left.length; i++) {
          if (tryOut([...deal, left[i]], [...left]..removeAt(i))) return true;
        }
        return false;
      }

      if (tryOut(const [], ours)) return group;
    }
    return null;
  }

  /// Whether no group can better all of its members at once.
  static bool settled(List<List<int>> street, List<int> where) =>
      blockers(street, where, firmly: false) == null;

  /// Whether no group can better any of its members without setting
  /// another back. Exactly one lane passes this on every street, and
  /// that is the theorem.
  static bool firm(List<List<int>> street, List<int> where) =>
      blockers(street, where, firmly: true) == null;

  /// Whether every tenant would rather be here than in the cottage they
  /// own.
  static bool allBetter(List<List<int>> street, List<int> where) {
    for (var t = 0; t < cottages; t++) {
      if (!rather(street, t, where[t], t)) return false;
    }
    return true;
  }

  /// Whether every tenant would rather be here than in [than].
  static bool allBetterThan(
      List<List<int>> street, List<int> where, List<int> than) {
    for (var t = 0; t < cottages; t++) {
      if (!rather(street, t, where[t], than[t])) return false;
    }
    return true;
  }

  /// The second voice, and a different idea altogether: nobody is
  /// asked whether they could do better. Every tenant points at whoever
  /// owns the cottage they want most; the pointing must close into
  /// rings; everybody in a ring takes the cottage they pointed at, and
  /// walks out of the lane. Repeat with what is left.
  ///
  /// This is the trading-rings reading, which Shapley and Scarf credited
  /// to Gale in 1974.
  static List<int> rings(List<List<int>> street) {
    final where = List.filled(cottages, -1);
    final gone = List.filled(cottages, false);
    while (where.contains(-1)) {
      // Each tenant still here points at the owner of the best cottage
      // still going.
      final points = List.filled(cottages, -1);
      for (var t = 0; t < cottages; t++) {
        if (gone[t]) continue;
        for (final want in street[t]) {
          if (!gone[want]) {
            points[t] = want;
            break;
          }
        }
      }
      // Follow the pointing until it comes back on itself.
      var at = points.indexWhere((p) => p >= 0);
      final walked = <int>[];
      while (!walked.contains(at)) {
        walked.add(at);
        at = points[at];
      }
      final ring = walked.sublist(walked.indexOf(at));
      for (final t in ring) {
        where[t] = points[t];
        gone[t] = true;
      }
    }
    return where;
  }

  /// The tenants who end up in the cottage they wanted most.
  static List<int> topped(List<List<int>> street, List<int> where) => [
        for (var t = 0; t < cottages; t++)
          if (street[t][0] == where[t]) t,
      ];

  /// The lanes that land an ask, ask by ask, worked out once.
  static List<List<int>> landings(
          List<List<int>> street, bool Function(List<int>) meets) =>
      [
        for (final where in allocations())
          if (meets(where)) where,
      ];
}
