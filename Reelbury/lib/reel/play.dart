import 'hall.dart';
import 'rounds.dart';
import 'stable.dart';

/// A round being paired up.
///
/// Which dancer each caller has, and nothing else. Everything the game says
/// about a pairing (whether it holds, who would rather have whom, how far off
/// it is) comes out of that and the hall, so there is no second copy of
/// anything to go stale.
class Play {
  const Play._(this.round, this.hall, this._with, this.changes);

  factory Play.of(Round round) => Play._(
        round,
        round.hall,
        List<int>.filled(round.count, -1),
        0,
      );

  final Round round;
  final Hall hall;
  final List<int> _with;

  /// How many times a pair has been made or broken.
  final int changes;

  int get count => hall.count;

  /// The dancer a caller has, or -1.
  int dancerOf(int caller) => _with[caller];

  /// The caller a dancer has, or -1.
  int callerOf(int dancer) {
    for (var caller = 0; caller < count; caller++) {
      if (_with[caller] == dancer) return caller;
    }
    return -1;
  }

  bool isPaired(int caller, int dancer) => _with[caller] == dancer;

  /// How many couples are on the floor.
  int get paired => _with.where((who) => who >= 0).length;

  bool get isFull => paired == count;

  /// The pairs who would both rather have each other than what they have got.
  List<Blocking> get blocking => Stable.blocking(hall, _with);

  /// Everybody paired, and nobody wanting to swap.
  bool get isDone => isFull && blocking.isEmpty;

  /// This round with two people put together.
  ///
  /// Whatever either of them was paired with is broken off, because a person
  /// cannot be in two couples and a game that made you break the old one
  /// first would be a game about tapping rather than about pairing.
  Play pair(int caller, int dancer) {
    if (caller < 0 || caller >= count || dancer < 0 || dancer >= count) {
      return this;
    }
    if (_with[caller] == dancer) return this;

    final next = List.of(_with);
    for (var who = 0; who < count; who++) {
      if (next[who] == dancer) next[who] = -1;
    }
    next[caller] = dancer;
    return Play._(round, hall, next, changes + 1);
  }

  /// This round with a caller's couple broken off.
  Play part(int caller) {
    if (_with[caller] < 0) return this;
    final next = List.of(_with);
    next[caller] = -1;
    return Play._(round, hall, next, changes + 1);
  }

  Play get again => Play.of(round);

  /// The one pairing that holds, which is what the round was chosen for.
  List<int> get answer => Stable.byAsking(hall);

  /// How many couples are not the ones in the answer.
  int get wrong {
    final want = answer;
    var off = 0;
    for (var caller = 0; caller < count; caller++) {
      if (_with[caller] != want[caller]) off++;
    }
    return off;
  }
}
