import 'ladder.dart';

/// Works out the fewest drops that are certain, and what to drop next.
///
/// There is no batch chosen at the start. The game keeps the set of answers
/// still possible, and when a pot is dropped it breaks or survives so as to
/// leave the most work still to do. So a number here is a promise about every
/// batch there could be, not a hope about one.
///
/// The searching is a minimax over (how many answers are left, pots in hand):
/// dropping from a rung splits the answers into the part below it and the
/// part from it up, the referee keeps the worse part, and a break costs a
/// pot. Only the counts matter, not which rungs, which is what keeps the
/// table tiny.
class Drops {
  Drops(this.pots) {
    _fewest = [
      for (var hand = 0; hand <= pots; hand++) <int>[0, 0],
    ];
  }

  final int pots;

  /// _fewest[hand][answers] once filled: the fewest drops certain to bring
  /// that many answers down to one with that many pots in hand.
  late final List<List<int>> _fewest;

  /// The fewest drops certain to settle [answers] possibilities with [hand]
  /// pots. With no pots left nothing can be asked, so more than one answer is
  /// unsettleable; that never comes up in play because the last pot's break
  /// settles everything below it only when the play was sound.
  int fewestFor(int answers, int hand) {
    if (answers <= 1) return 0;
    if (hand == 0) return 1 << 20;

    final table = _fewest[hand];
    while (table.length <= answers) {
      final many = table.length;
      var best = 1 << 20;
      // Split the answers: the break side gets `below`, the survive side the
      // rest. Every split from 1..many-1 is a rung somebody could choose.
      for (var below = 1; below < many; below++) {
        final broke = fewestFor(below, hand - 1);
        final lived = fewestFor(many - below, hand);
        final worse = broke > lived ? broke : lived;
        if (worse + 1 < best) best = worse + 1;
      }
      table.add(best);
    }
    return table[answers];
  }

  /// The rung to drop from, given what is still possible: one whose worse
  /// half still settles in as few drops as the whole can.
  int rungFor(Standing standing, int hand) {
    final many = standing.answers;
    final whole = fewestFor(many, hand);
    for (var below = 1; below < many; below++) {
      final broke = fewestFor(below, hand - 1);
      final lived = fewestFor(many - below, hand);
      final worse = broke > lived ? broke : lived;
      if (worse + 1 == whole) return standing.lowest + below;
    }
    return standing.lowest + 1;
  }

  /// Which way the pot goes: the referee keeps the half that needs more
  /// drops, and the bigger half when the two need the same.
  bool breaksAt(Standing standing, int rung, int hand) {
    final below = rung - standing.lowest;
    final lived = standing.answers - below;
    final brokeCost = fewestFor(below, hand - 1);
    final livedCost = fewestFor(lived, hand);
    if (brokeCost != livedCost) return brokeCost > livedCost;
    return below >= lived;
  }

  /// What counting alone says: d drops with p pots can tell apart at most
  /// choose(d,1) + choose(d,2) + ... + choose(d,p) answers beyond the first.
  ///
  /// Each drop breaks or does not, and a run of drops is a word of breaks and
  /// survivals with at most p breaks in it; there are that many words, and
  /// two answers that would read the same word can never be told apart. What
  /// makes this floor worth the name is that it is exactly the answer, for
  /// every ladder and every handful of pots, and a test says so.
  static int countingSays(int answers, int pots) {
    var drops = 0;
    while (tellsApart(drops, pots) < answers) {
      drops++;
    }
    return drops;
  }

  /// How many answers [drops] drops with [pots] pots can tell apart.
  static int tellsApart(int drops, int pots) {
    var total = 1;
    var choose = 1;
    for (var take = 1; take <= pots && take <= drops; take++) {
      choose = choose * (drops - take + 1) ~/ take;
      total += choose;
    }
    return total;
  }
}
