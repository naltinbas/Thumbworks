/// One fuse: how much burning it has left, in quarter-minutes, and how
/// many of its two ends are alight.
typedef Fuse = (int left, int ends);

/// The law of the fuses: each burns an hour end to end, unevenly, so
/// only two things are sure, that a fuse lit at one end is gone in what
/// is left of its hour, and one lit at both ends in half that; and you
/// can only act at the start and when a fuse burns out.
class Rules {
  /// Quarter-minutes to the minute; sixty minutes to a fuse.
  static const quarter = 4;
  static const hour = 60 * quarter;

  static List<Fuse> fresh(int count) => List.filled(count, (hour, 0));

  /// The next burnout from now: the least time a lit fuse needs, in
  /// quarter-minutes; null when nothing is alight. A fuse lit at both
  /// ends burns twice as fast.
  static int? nextBurnout(List<Fuse> fuses) {
    int? soonest;
    for (final (left, ends) in fuses) {
      if (ends == 0 || left == 0) continue;
      // left / ends, exact when even; halves are kept in quarters.
      final t = left ~/ ends;
      if (soonest == null || t < soonest) soonest = t;
    }
    return soonest;
  }

  /// The fuses after [dt] quarter-minutes of burning.
  static List<Fuse> burned(List<Fuse> fuses, int dt) => [
        for (final (left, ends) in fuses)
          ends == 0 || left == 0 ? (left, ends) : ((left - ends * dt) < 0 ? 0 : left - ends * dt, ends),
      ];

  /// Whether every burnout lands on whole quarter-minutes: it does when
  /// the fuses' lengths stay even in quarters, which halving an hour
  /// four times allows.
  static bool wholeQuarters(List<Fuse> fuses) => fuses.every((f) => f.$1 % f.$2.clamp(1, 2) == 0);

  /// Every plan of lighting [count] fuses, and the burnout times each
  /// reaches: a plan lights any unlit ends at the start and at every
  /// burnout, until nothing is alight. Returns the times any plan
  /// strikes, and how many plans strike [asked], and how many plans
  /// there are in all.
  static (Set<int> times, int striking, int plans) sweep(int count, int asked) {
    final times = <int>{};
    var striking = 0, plans = 0;
    void grow(int now, List<Fuse> fuses, bool struck) {
      // Choices: for each fuse with something left, light 0, 1 or 2 more ends.
      final options = <List<int>>[
        for (final (left, ends) in fuses) left == 0 ? [0] : [for (var k = 0; k + ends <= 2; k++) k],
      ];
      final choice = List.filled(fuses.length, 0);
      void pick(int i) {
        if (i == fuses.length) {
          final lit = [for (var k = 0; k < fuses.length; k++) (fuses[k].$1, fuses[k].$2 + choice[k])];
          final dt = nextBurnout(lit);
          if (dt == null) {
            // Nothing alight: the plan ends here.
            plans++;
            if (struck) striking++;
            return;
          }
          final then = now + dt;
          times.add(then);
          grow(then, burned(lit, dt), struck || then == asked);
          return;
        }
        for (final k in options[i]) {
          choice[i] = k;
          pick(i + 1);
        }
      }

      pick(0);
    }

    grow(0, fresh(count), false);
    return (times, striking, plans);
  }

  /// The first plan that strikes [asked], as the list of lightings to
  /// make: each entry (time, fuse, ends to light). Null when none does.
  static List<(int, int, int)>? plan(int count, int asked) {
    List<(int, int, int)>? found;
    final trail = <(int, int, int)>[];
    void grow(int now, List<Fuse> fuses) {
      if (found != null) return;
      final options = <List<int>>[
        for (final (left, ends) in fuses) left == 0 ? [0] : [for (var k = 0; k + ends <= 2; k++) k],
      ];
      final choice = List.filled(fuses.length, 0);
      void pick(int i) {
        if (found != null) return;
        if (i == fuses.length) {
          final lit = [for (var k = 0; k < fuses.length; k++) (fuses[k].$1, fuses[k].$2 + choice[k])];
          final dt = nextBurnout(lit);
          if (dt == null) return;
          final then = now + dt;
          final added = <(int, int, int)>[for (var k = 0; k < fuses.length; k++) if (choice[k] > 0) (now, k, choice[k])];
          trail.addAll(added);
          if (then == asked) {
            found = List.of(trail);
          } else if (then < asked) {
            grow(then, burned(lit, dt));
          }
          trail.removeRange(trail.length - added.length, trail.length);
          return;
        }
        for (final k in options[i]) {
          choice[i] = k;
          pick(i + 1);
        }
      }

      pick(0);
    }

    grow(0, fresh(count));
    return found;
  }
}
