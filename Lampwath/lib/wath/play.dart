import 'bridge.dart';
import 'fewest.dart';

/// One crossing that has happened: who walked, which way, and what it cost.
class Crossed {
  const Crossed(this.party, this.toFar, this.minutes);

  final int party;
  final bool toFar;
  final int minutes;
}

/// A night part way through.
class Play {
  Play._(this.bridge, this.crossings, this.done, this.chosen);

  factory Play.of(Bridge bridge, Crossings crossings) =>
      Play._(bridge, crossings, const [], 0);

  final Bridge bridge;

  /// The settled distances, kept for as long as the night lasts.
  final Crossings crossings;

  /// Every crossing so far, in order.
  final List<Crossed> done;

  /// Who is picked to cross next, as bits. At most two, on the lantern's
  /// bank.
  final int chosen;

  /// Who stands on the far bank, as bits.
  int get over {
    var bits = 0;
    for (final crossing in done) {
      bits = crossing.toFar ? bits | crossing.party : bits & ~crossing.party;
    }
    return bits;
  }

  /// Whether the lantern is on the far bank.
  bool get lampFar => done.isNotEmpty && done.last.toFar;

  /// Minutes spent so far.
  int get spent =>
      done.fold(0, (sum, crossing) => sum + crossing.minutes);

  bool get isDone => over == bridge.everyone;

  bool get isFewest => isDone && spent <= bridge.fewest;

  bool onFar(int walker) => (over & (1 << walker)) != 0;

  bool isChosen(int walker) => (chosen & (1 << walker)) != 0;

  /// How many are picked.
  int get chosenCount {
    var count = 0;
    for (var walker = 0; walker < bridge.count; walker++) {
      if (isChosen(walker)) count++;
    }
    return count;
  }

  /// What the picked party would cost.
  int get chosenMinutes {
    var slower = 0;
    for (var walker = 0; walker < bridge.count; walker++) {
      if (!isChosen(walker)) continue;
      if (bridge.walkers[walker].minutes > slower) {
        slower = bridge.walkers[walker].minutes;
      }
    }
    return slower;
  }

  /// Picks a walker for the crossing, or puts them back. Only walkers on the
  /// lantern's bank can be picked, and no more than two.
  Play pick(int walker) {
    if (isDone || walker < 0 || walker >= bridge.count) return this;
    if (onFar(walker) != lampFar) return this;
    if (isChosen(walker)) {
      return Play._(bridge, crossings, done, chosen & ~(1 << walker));
    }
    if (chosenCount >= 2) return this;
    return Play._(bridge, crossings, done, chosen | (1 << walker));
  }

  /// Sends the picked party across with the lantern.
  Play cross() {
    if (isDone || chosen == 0) return this;
    return Play._(
      bridge,
      crossings,
      [...done, Crossed(chosen, !lampFar, chosenMinutes)],
      0,
    );
  }

  Play get back => done.isEmpty
      ? this
      : Play._(bridge, crossings, done.sublist(0, done.length - 1), 0);

  Play get again => Play.of(bridge, crossings);

  /// The fewest minutes still needed from here.
  int get left => crossings.from(over, lampFar);

  /// The best this night can now come to, counting the minutes spent.
  int get couldFinishIn => spent + left;

  /// Asked. The party to send next on a fewest way, as bits.
  int? get next => crossings.nextFrom(over, lampFar);
}
