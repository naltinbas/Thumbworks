/// The law of the banns.
///
/// A party is people numbered from nought, each ranking some of the
/// others. A pairing weds everyone off two by two. Two people are an
/// eloping pair when each ranks the other above whoever they were
/// wedded to: a pairing with none is settled, and the game is to find
/// one.
///
/// Everything the game claims is checked two ways that share nothing: a
/// sweep of every pairing there is, and for the two-sided parties the
/// old asking-round, run move by move. Neither is trusted alone.
class Rules {
  Rules(this.prefs) : people = prefs.length;

  /// Each person's ranking, best first, over the people they would
  /// have at all.
  final List<List<int>> prefs;

  final int people;

  /// How person `who` ranks `other`: nought for their first choice, and
  /// null for someone they would not have.
  int? standing(int who, int other) {
    final at = prefs[who].indexOf(other);
    return at < 0 ? null : at;
  }

  /// Whether `who` would rather have `other` than `instead`. Nobody, as
  /// null, loses to anyone ranked at all.
  bool prefers(int who, int other, int? instead) {
    final that = standing(who, other);
    if (that == null) return false;
    if (instead == null) return true;
    final held = standing(who, instead);
    return held == null || that < held;
  }

  /// The eloping pairs: two wedded people who would both rather have
  /// each other than what they hold. Singles are left in peace, so a
  /// half-made pairing is not painted red for being half made; on a
  /// complete pairing this is the old definition exactly.
  List<(int, int)> eloping(List<int?> wedded) => [
        for (var one = 0; one < people; one++)
          for (var other = one + 1; other < people; other++)
            if (wedded[one] != null &&
                wedded[other] != null &&
                prefers(one, other, wedded[one]) &&
                prefers(other, one, wedded[other]))
              (one, other),
      ];

  /// Whether a pairing weds everyone with nobody eloping.
  bool settled(List<int?> wedded) {
    for (final partner in wedded) {
      if (partner == null) return false;
    }
    return eloping(wedded).isEmpty;
  }

  /// Every complete pairing of everyone, willing or not: the sweeps
  /// judge them, this only lists them.
  Iterable<List<int>> allPairings() sync* {
    final wedded = List<int>.filled(people, -1);
    yield* _paired(wedded);
  }

  Iterable<List<int>> _paired(List<int> wedded) sync* {
    var first = -1;
    for (var who = 0; who < people; who++) {
      if (wedded[who] < 0) {
        first = who;
        break;
      }
    }
    if (first < 0) {
      yield [...wedded];
      return;
    }
    for (var other = first + 1; other < people; other++) {
      if (wedded[other] >= 0) continue;
      wedded[first] = other;
      wedded[other] = first;
      yield* _paired(wedded);
      wedded[first] = -1;
      wedded[other] = -1;
    }
  }

  /// Every settled pairing there is, found by the sweep.
  List<List<int>> settledPairings() => [
        for (final pairing in allPairings())
          if (settled(pairing)) pairing,
      ];

  /// The asking-round for a two-sided party: the first half ask, the
  /// second half keep the best asker so far. Ends settled, always, when
  /// each side ranks all of the other; the suite checks the ending
  /// rather than the folklore.
  ///
  /// Askers are people 0 to half-1; kept are half to people-1.
  List<int> askingRound() {
    final half = people ~/ 2;
    final held = List<int?>.filled(people, null);
    final askedTo = List<int>.filled(half, 0);
    var free = [for (var who = 0; who < half; who++) who];

    while (free.isNotEmpty) {
      final asker = free.removeAt(0);
      final wanted = prefs[asker][askedTo[asker]];
      askedTo[asker]++;
      final holding = held[wanted];
      if (holding == null) {
        held[wanted] = asker;
        held[asker] = wanted;
      } else if (prefers(wanted, asker, holding)) {
        held[wanted] = asker;
        held[asker] = wanted;
        held[holding] = null;
        free.add(holding);
      } else {
        free.add(asker);
      }
    }
    return [for (final partner in held) partner!];
  }
}
