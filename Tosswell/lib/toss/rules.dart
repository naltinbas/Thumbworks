/// Five tosses of a fair coin. Heads and the purse goes up a shilling,
/// tails and it goes down one. Before each toss you may walk away with
/// what you have.
///
/// A rule for walking away is a set of standings to stop at. The board
/// draws the standings as a lattice: how many tosses have gone across,
/// what the purse holds up and down. Mark a standing and the run stops
/// there.
///
/// Whatever rule you pick, the purse averages nothing over the 32 runs.
/// That is Doob's optional stopping theorem for a bounded rule on a
/// fair game: the walk is a martingale, so no rule for leaving it can
/// change what it is worth.
class Rules {
  static const tosses = 5;

  /// How many runs of the coin there are.
  static int get runs => 1 << tosses;

  /// The standings a rule may stop at: every one but the last row,
  /// where the tossing is over anyway.
  static List<(int, int)> standings() => [
        for (var toss = 0; toss < tosses; toss++)
          for (var purse = -toss; purse <= toss; purse += 2) (toss, purse),
      ];

  static int get howManyStandings => standings().length;

  /// Whether a standing is one the coin can reach.
  static bool reachable((int, int) at) =>
      at.$1 >= 0 &&
      at.$1 <= tosses &&
      at.$2.abs() <= at.$1 &&
      (at.$1 - at.$2).isEven;

  /// Where each of the 32 runs ends under a rule, in the order the runs
  /// are listed: heads first.
  static List<int> ends(Set<String> stop) {
    final out = <int>[];
    for (var run = 0; run < runs; run++) {
      var toss = 0, purse = 0;
      while (toss < tosses) {
        if (stop.contains(mark((toss, purse)))) break;
        purse += (run >> toss & 1) == 0 ? 1 : -1;
        toss++;
      }
      out.add(purse);
    }
    return out;
  }

  /// Where a run stops under a rule: the standing it walks away from.
  static (int, int) stopsAt(Set<String> stop, int run) {
    var toss = 0, purse = 0;
    while (toss < tosses) {
      if (stop.contains(mark((toss, purse)))) break;
      purse += (run >> toss & 1) == 0 ? 1 : -1;
      toss++;
    }
    return (toss, purse);
  }

  /// How many of the runs each standing is walked away from.
  static Map<String, int> ending(Set<String> stop) {
    final out = <String, int>{};
    for (var run = 0; run < runs; run++) {
      final at = mark(stopsAt(stop, run));
      out[at] = (out[at] ?? 0) + 1;
    }
    return out;
  }

  /// Whether the coin can still reach a standing under a rule, or
  /// whether the rule has stopped every run that would pass through it.
  static bool alive(Set<String> stop, (int, int) at) {
    if (!reachable(at)) return false;
    for (var run = 0; run < runs; run++) {
      var toss = 0, purse = 0;
      while (toss < tosses) {
        if ((toss, purse) == at) return true;
        if (stop.contains(mark((toss, purse)))) break;
        purse += (run >> toss & 1) == 0 ? 1 : -1;
        toss++;
      }
      if ((toss, purse) == at) return true;
    }
    return false;
  }

  static String mark((int, int) at) => '${at.$1},${at.$2}';

  /// The purse added over all 32 runs, which is nothing whatever the
  /// rule.
  static int added(List<int> ends) {
    var out = 0;
    for (final end in ends) {
      out += end;
    }
    return out;
  }

  static int aheadIn(List<int> ends) {
    var out = 0;
    for (final end in ends) {
      if (end > 0) out++;
    }
    return out;
  }

  static int worstIn(List<int> ends) {
    var out = ends.first;
    for (final end in ends) {
      if (end < out) out = end;
    }
    return out;
  }

  static int bestIn(List<int> ends) {
    var out = ends.first;
    for (final end in ends) {
      if (end > out) out = end;
    }
    return out;
  }

  static String tellStanding((int, int) at) =>
      'the standing after ${at.$1} ${at.$1 == 1 ? 'toss' : 'tosses'} at '
      '${at.$2 > 0 ? '${at.$2} up' : at.$2 < 0 ? '${-at.$2} down' : 'level'}';

  static String tellPurse(int purse) => purse > 0
      ? '$purse up'
      : purse < 0
          ? '${-purse} down'
          : 'level';
}
