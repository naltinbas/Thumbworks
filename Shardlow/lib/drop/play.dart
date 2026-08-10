import 'fewest.dart';
import 'ladder.dart';

/// One drop that has happened: the rung, and what became of the pot.
class Dropped {
  const Dropped(this.rung, this.broke);

  final int rung;
  final bool broke;
}

/// A morning part way through.
class Play {
  Play._(this.ladder, this.drops, this.done);

  factory Play.of(Ladder ladder, Drops drops) =>
      Play._(ladder, drops, const []);

  final Ladder ladder;

  /// The table of fewest drops, kept for as long as the morning lasts.
  final Drops drops;

  /// Every drop so far, in order.
  final List<Dropped> done;

  /// What is still possible.
  Standing get standing {
    var lowest = 0;
    var highest = ladder.rungs;
    for (final drop in done) {
      if (drop.broke) {
        if (drop.rung - 1 < highest) highest = drop.rung - 1;
      } else {
        if (drop.rung > lowest) lowest = drop.rung;
      }
    }
    return Standing(lowest: lowest, highest: highest);
  }

  int get made => done.length;

  /// Pots still whole.
  int get hand => ladder.pots - done.where((drop) => drop.broke).length;

  bool get isDone => standing.settled;

  /// The answer, once it is settled.
  int? get answer => isDone ? standing.lowest : null;

  bool get isFewest => isDone && made <= ladder.fewest;

  /// What became of each rung, for the drawing: 1 broke, 0 survived, -1
  /// nothing yet. The latest word wins, though sound play never asks twice.
  int wordOn(int rung) {
    for (final drop in done.reversed) {
      if (drop.rung == rung) return drop.broke ? 1 : 0;
    }
    return -1;
  }

  /// Whether a rung is still worth dropping from.
  bool worthDropping(int rung) => standing.worthDropping(rung);

  /// Drops a pot from a rung. The referee decides whether it breaks: whatever
  /// leaves the most work still to do, so the answer is a promise about every
  /// batch there could be.
  Play drop(int rung) {
    if (isDone || !worthDropping(rung)) return this;
    final broke = drops.breaksAt(standing, rung, hand);
    return Play._(ladder, drops, [...done, Dropped(rung, broke)]);
  }

  Play get back => done.isEmpty
      ? this
      : Play._(ladder, drops, done.sublist(0, done.length - 1));

  Play get again => Play.of(ladder, drops);

  /// The fewest drops still needed from here.
  int get left => drops.fewestFor(standing.answers, hand);

  /// The best this morning can now come to, counting the drops made.
  int get couldFinishIn => made + left;

  /// Asked. The rung to drop from that keeps the total where it is.
  int? get next => isDone ? null : drops.rungFor(standing, hand);
}
