/// The two answers: the wheel, and the search.
///
/// A fixture card for an even number of sides: every side plays every
/// other exactly once, one match per side per round. The pigeonhole says
/// a card cannot be shorter than sides-less-one rounds: each side has
/// sides-less-one opponents and meets at most one a round.
///
/// The wheel says that bound is exact, by building the card: sit one
/// side at the hub and the rest round a rim; each round the hub plays
/// whoever the turning has brought to the top, and the rim pairs off
/// across itself; then the rim turns one notch. Every pair differs by a
/// fresh turning, so no pair repeats, and the sweep checks every pair of
/// every size is met exactly once.
class Rules {
  const Rules._();

  /// The wheel's pairings for [round] of [sides] sides: a list of
  /// (a, b) matches. Sides are numbered, the hub is the last.
  static List<(int, int)> wheelRound(int sides, int round) {
    final rim = sides - 1;
    final matches = <(int, int)>[];
    // The hub plays the rim side at notch [round].
    matches.add((round % rim, sides - 1));
    // The rest of the rim pairs off across the turned circle.
    for (var step = 1; step <= (rim - 1) ~/ 2; step++) {
      final one = (round + step) % rim;
      final other = (round - step + rim * 2) % rim;
      matches.add(one < other ? (one, other) : (other, one));
    }
    return matches;
  }

  /// Whether a part-built card can still be finished: [met] holds pairs
  /// already played in finished rounds, [current] the matches of the
  /// round being built, with [roundsLeft] rounds after this one.
  ///
  /// The search completes the current round to a perfect pairing of the
  /// free sides, then fills the remaining rounds, backtracking.
  static bool canStillFinish(
    int sides,
    Set<int> met,
    List<(int, int)> current,
    int roundsLeft,
  ) {
    final free = <int>{for (var side = 0; side < sides; side++) side};
    final tried = <int>{...met};
    for (final (a, b) in current) {
      free.remove(a);
      free.remove(b);
      tried.add(_key(sides, a, b));
    }
    return _finishRound(sides, tried, free, roundsLeft);
  }

  static int _key(int sides, int a, int b) =>
      a < b ? a * sides + b : b * sides + a;

  static bool _finishRound(
      int sides, Set<int> met, Set<int> free, int roundsLeft) {
    if (free.isEmpty) {
      // Round complete: all pairs met? done; else start the next round.
      if (met.length == sides * (sides - 1) ~/ 2) return true;
      if (roundsLeft <= 0) return false;
      // The pigeonhole, before anything else: a side with more unmet
      // opponents than rounds left can never finish, and saying so here
      // is what keeps the refutations quick.
      for (var side = 0; side < sides; side++) {
        var unmet = 0;
        for (var other = 0; other < sides; other++) {
          if (other == side) continue;
          if (!met.contains(_key(sides, side, other))) unmet++;
        }
        if (unmet > roundsLeft) return false;
      }
      return _finishRound(
        sides,
        met,
        {for (var side = 0; side < sides; side++) side},
        roundsLeft - 1,
      );
    }
    // Fail first: pair the free side with the fewest free unmet partners.
    var a = -1;
    var fewest = 1 << 20;
    for (final side in free) {
      var options = 0;
      for (final other in free) {
        if (other == side) continue;
        if (!met.contains(_key(sides, side, other))) options++;
      }
      if (options < fewest) {
        fewest = options;
        a = side;
      }
    }
    if (fewest == 0) return false;
    for (final b in [...free]) {
      if (b == a) continue;
      final key = _key(sides, a, b);
      if (met.contains(key)) continue;
      met.add(key);
      free.remove(a);
      free.remove(b);
      if (_finishRound(sides, met, free, roundsLeft)) {
        met.remove(key);
        free.add(a);
        free.add(b);
        return true;
      }
      met.remove(key);
      free.add(a);
      free.add(b);
    }
    return false;
  }
}
