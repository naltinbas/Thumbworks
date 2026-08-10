import 'extent.dart';
import 'peals.dart';
import 'tower.dart';

/// One pull that has happened: the change rung, and the row it brought.
class Pulled {
  const Pulled(this.change, this.row);

  final Change change;
  final BellRow row;
}

/// A peal part rung.
class Play {
  Play._(this.peal, this.extent, this.done);

  factory Play.of(Peal peal, Extent extent) => Play._(peal, extent, const []);

  final Peal peal;

  /// The search, kept for as long as the peal is being rung.
  final Extent extent;

  /// Every pull so far, in order.
  final List<Pulled> done;

  Tower get tower => peal.tower;

  /// The row sounding now.
  BellRow get at => done.isEmpty ? tower.rounds : done.last.row;

  /// The distinct rows sounded so far, rounds among them, as packed keys.
  Set<int> get rung => {
        tower.keyOf(tower.rounds),
        for (final pull in done) tower.keyOf(pull.row),
      };

  int get made => done.length;

  /// Whether rounds has struck home with every goal row sounded.
  bool get isDone =>
      done.isNotEmpty &&
      tower.keyOf(at) == tower.keyOf(tower.rounds) &&
      rung.length == peal.goalRows;

  /// Whether a change may be rung now: it must bring a row not yet sounded,
  /// or bring rounds home once everything else has.
  bool mayRing(Change change) {
    if (isDone) return false;
    final next = change.apply(at);
    final key = tower.keyOf(next);
    if (key == tower.keyOf(tower.rounds)) {
      return rung.length == peal.goalRows;
    }
    return !rung.contains(key);
  }

  Play pull(Change change) {
    if (!mayRing(change)) return this;
    return Play._(peal, extent, [...done, Pulled(change, change.apply(at))]);
  }

  Play get back => done.isEmpty
      ? this
      : Play._(peal, extent, done.sublist(0, done.length - 1));

  Play get again => Play.of(peal, extent);

  /// Whether the peal can still be brought home from here.
  bool get canStillRing => isDone || extent.canFinish(at, rung);

  /// Whether nothing at all may be rung.
  bool get isStuck => !isDone && !tower.changes.any(mayRing);

  /// Asked. A change that keeps the peal alive, or null.
  Change? get next => isDone ? null : extent.nextFrom(at, rung);
}
