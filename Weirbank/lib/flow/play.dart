import 'most.dart';
import 'works.dart';

/// A pond where more arrives than leaves, or the other way about.
class Spill {
  const Spill(this.pond, this.over);

  final int pond;

  /// How much more comes in than goes out. Negative means the other way,
  /// which is a pond sending water it never received.
  final int over;
}

/// A works being set.
///
/// The player's only decision is how much goes down each pipe. Everything the
/// game says comes out of that list and the works, so there is no second copy
/// of anything to go stale.
class Play {
  const Play._(this.works, this.down, this.target, this.turns);

  factory Play.of(Works works, int target) =>
      Play._(works, List<int>.filled(works.pipes.length, 0), target, 0);

  final Works works;

  /// How much the player has sent down each pipe.
  final List<int> down;

  /// How much has to reach the mill.
  final int target;

  /// How many times a pipe has been turned.
  final int turns;

  int downPipe(int pipe) => down[pipe];

  /// How much leaves the spring, and how much arrives at the mill.
  int get leaving => _out(works.spring) - _in(works.spring);
  int get arriving => _in(works.mill) - _out(works.mill);

  int _in(int pond) {
    var total = 0;
    for (final pipe in works.into(pond)) {
      total += down[pipe];
    }
    return total;
  }

  int _out(int pond) {
    var total = 0;
    for (final pipe in works.out(pond)) {
      total += down[pipe];
    }
    return total;
  }

  /// The ponds where the water does not add up. The spring and the mill are
  /// allowed to, since that is what they are for.
  List<Spill> get spills => [
        for (var pond = 0; pond < works.count; pond++)
          if (pond != works.spring && pond != works.mill && _in(pond) != _out(pond))
            Spill(pond, _in(pond) - _out(pond)),
      ];

  bool get holds => spills.isEmpty;

  /// Every pipe is within what it holds, nothing spills, and the mill has
  /// what it asked for.
  bool get isDone => holds && arriving >= target;

  /// This works with one more going down a pipe, or none at all when it was
  /// already full.
  ///
  /// Turning past full comes back to nothing on purpose: it is one tap for
  /// every amount a pipe can carry, in a game where the amounts are small,
  /// and it means a pipe can be emptied without a second control.
  Play turn(int pipe) {
    if (pipe < 0 || pipe >= down.length) return this;
    final next = List.of(down);
    next[pipe] = next[pipe] >= works.pipes[pipe].holds ? 0 : next[pipe] + 1;
    return Play._(works, next, target, turns + 1);
  }

  /// This works with a pipe emptied.
  Play empty(int pipe) {
    if (pipe < 0 || pipe >= down.length || down[pipe] == 0) return this;
    final next = List.of(down);
    next[pipe] = 0;
    return Play._(works, next, target, turns + 1);
  }

  Play get again => Play.of(works, target);

  /// The answer, worked out from the works rather than stored.
  Most get answer => Flow(works).work();
}
