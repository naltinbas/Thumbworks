import 'green.dart';
import 'rules.dart';

/// A card part written: the rounds so far, and the round in hand.
class Play {
  const Play._(
    this.green,
    this.rounds,
    this.current,
    this.chosen,
    this.before,
  );

  Play.of(Green green) : this._(green, const [], const [], -1, null);

  final Green green;

  /// The rounds already written, each a full pairing.
  final List<List<(int, int)>> rounds;

  /// The matches of the round in hand.
  final List<(int, int)> current;

  /// A side picked and waiting for its opponent, or -1.
  final int chosen;

  /// The card before the last pairing, or null at the start.
  final Play? before;

  /// Pairs already met, over finished rounds and the round in hand.
  Set<int> get met => {
        for (final round in rounds)
          for (final (a, b) in round) _key(a, b),
        for (final (a, b) in current) _key(a, b),
      };

  int _key(int a, int b) =>
      a < b ? a * green.sides + b : b * green.sides + a;

  bool haveMet(int a, int b) => met.contains(_key(a, b));

  /// Whether a side is already paired this round.
  bool busy(int side) {
    for (final (a, b) in current) {
      if (a == side || b == side) return true;
    }
    return false;
  }

  int get matchesMade =>
      rounds.fold(0, (sum, round) => sum + round.length) + current.length;

  bool get isWritten => matchesMade == green.pairs;

  /// Picks a side, or pairs it with the one already picked. Unpicks on
  /// the same side twice.
  Play pick(int side) {
    if (isWritten || side < 0 || side >= green.sides || busy(side)) {
      return this;
    }
    if (chosen == -1) {
      return Play._(green, rounds, current, side, before);
    }
    if (chosen == side) {
      return Play._(green, rounds, current, -1, before);
    }
    if (haveMet(chosen, side)) return this;
    final grown = [...current, (chosen, side)];
    if (grown.length == green.sides ~/ 2) {
      return Play._(green, [...rounds, grown], const [], -1, this);
    }
    return Play._(green, rounds, grown, -1, this);
  }

  /// The last pairing undone, or this at the start. Reopens a just-
  /// finished round when it must.
  Play get back => before ?? this;

  /// Which round is in hand, one-counted.
  int get roundInHand => rounds.length + 1;

  /// Whether the card can still be written from here.
  bool get canStill {
    if (isWritten) return true;
    final roundsAfterThis = green.rounds - rounds.length - 1;
    if (roundsAfterThis < 0) return false;
    return Rules.canStillFinish(
      green.sides,
      {
        for (final round in rounds)
          for (final (a, b) in round) _key(a, b),
      },
      current,
      roundsAfterThis,
    );
  }

  /// A pairing that keeps the card writable, as (a, b), or null.
  (int, int)? get next {
    if (isWritten || !canStill) return null;
    for (var a = 0; a < green.sides; a++) {
      if (busy(a)) continue;
      for (var b = a + 1; b < green.sides; b++) {
        if (busy(b) || haveMet(a, b)) continue;
        final tried = Play._(green, rounds, [...current, (a, b)], -1, this);
        if (tried.canStill) return (a, b);
      }
      return null;
    }
    return null;
  }
}
