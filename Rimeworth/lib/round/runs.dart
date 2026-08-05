import 'parish.dart';

/// How many runs a parish takes, and why.
class Round {
  const Round({
    required this.runs,
    required this.odd,
    required this.starts,
  });

  /// The fewest times the lorry has to set off.
  final int runs;

  /// The junctions with an odd number of lanes on them, which is the reason.
  final List<int> odd;

  /// The junctions a run may start at. Every odd junction, or every junction
  /// with a lane on it when there are none.
  final List<int> starts;

  bool get isOneRun => runs == 1;
}

/// Works out how many runs the lorry has to make, and lays them out.
///
/// The counting does not search. A lorry that drives into a junction drives
/// out again on another lane, so passing through uses lanes two at a time. A
/// junction with an odd number of lanes on it therefore has to be an end of
/// some run: either the lorry sets off from there, or it runs out of lanes
/// there. Each run has two ends, so with 2k odd junctions no fewer than k
/// runs will do, and k runs always suffice on a parish that hangs together.
///
/// A parish with no odd junctions at all takes one run, which comes back to
/// where it set off.
class Runs {
  const Runs._();

  static Round fewestFor(Parish parish) {
    final odd = parish.oddJunctions;
    final runs = odd.isEmpty ? 1 : odd.length ~/ 2;
    return Round(
      runs: runs,
      odd: odd,
      starts: odd.isNotEmpty
          ? odd
          : [
              for (var junction = 0; junction < parish.count; junction++)
                if (parish.lanesOn(junction) > 0) junction,
            ],
    );
  }

  /// Runs that salt every lane, as the junctions each one calls at in order.
  ///
  /// The odd junctions are paired off with lanes that are not there, which
  /// leaves every junction even. A parish where every junction is even can be
  /// driven in one closed run, and taking the imaginary lanes back out of
  /// that run cuts it into exactly the runs the counting asked for.
  static List<List<int>> routes(Parish parish) {
    if (parish.lanes.isEmpty) return const [];

    final odd = parish.oddJunctions;
    final real = parish.laneCount;

    // The working parish: every real lane, then one imaginary lane for each
    // pair of odd junctions.
    final ends = <(int, int)>[
      for (final lane in parish.lanes) (lane.from, lane.to),
      for (var pair = 0; pair < odd.length; pair += 2)
        (odd[pair], odd[pair + 1]),
    ];
    final at = List.generate(parish.count, (_) => <int>[]);
    for (var lane = 0; lane < ends.length; lane++) {
      at[ends[lane].$1].add(lane);
      at[ends[lane].$2].add(lane);
    }

    final from = odd.isNotEmpty ? odd.first : parish.lanes.first.from;
    return _cut(_circuit(ends, at, from), from, real);
  }

  /// One closed run over every lane, by Hierholzer's method: walk until stuck,
  /// then go back along what has been walked looking for a junction with a
  /// lane left and walk that in as well.
  ///
  /// Each step is the lane taken and the junction it came out at.
  static List<(int, int)> _circuit(
    List<(int, int)> ends,
    List<List<int>> at,
    int from,
  ) {
    final done = List.filled(ends.length, false);
    final next = List.filled(at.length, 0);

    // Junction, and the lane that was taken to get there.
    final stack = <(int, int)>[(from, -1)];
    final out = <(int, int)>[];

    while (stack.isNotEmpty) {
      final (here, came) = stack.last;

      var lane = -1;
      while (next[here] < at[here].length) {
        final maybe = at[here][next[here]];
        if (!done[maybe]) {
          lane = maybe;
          break;
        }
        next[here]++;
      }

      if (lane < 0) {
        stack.removeLast();
        if (came >= 0) out.add((came, here));
        continue;
      }

      done[lane] = true;
      final there = ends[lane].$1 == here ? ends[lane].$2 : ends[lane].$1;
      stack.add((there, lane));
    }

    return out.reversed.toList();
  }

  /// Cuts a closed run at the lanes that are not there, and gives back what
  /// is left as the junctions each real run calls at.
  static List<List<int>> _cut(List<(int, int)> tour, int from, int real) {
    // Where the tour is at each point, and the lane it took to get there.
    final at = <int>[from, for (final step in tour) step.$2];
    final took = [for (final step in tour) step.$1];

    // Nothing imaginary in it: the whole parish is one closed run.
    final cut = took.indexWhere((lane) => lane >= real);
    if (cut < 0) return [at];

    // Read round the tour from just after an imaginary lane, so that no real
    // run is left split across the two ends of the list.
    final runs = <List<int>>[];
    var run = <int>[];
    for (var step = 1; step <= took.length; step++) {
      final here = (cut + step) % took.length;
      if (took[here] >= real) {
        if (run.length > 1) runs.add(run);
        run = <int>[];
        continue;
      }
      if (run.isEmpty) run.add(at[here]);
      run.add(at[here + 1]);
    }
    if (run.length > 1) runs.add(run);
    return runs;
  }

  /// The same question answered by driving: the fewest runs there are, found
  /// by trying every way the lorry could actually go.
  ///
  /// This is here to hold the counting to account. It obeys the rules the
  /// screen obeys, which is the only kind of check worth having: the lorry
  /// stands at a junction, takes a lane it has not salted, and comes out at
  /// the other end. When it can go no further and lanes are left, it is
  /// lifted to any junction at all, and that costs a run.
  ///
  /// Every state it can be in is a junction, the lanes salted so far and the
  /// runs left, so states seen once are not looked at again. That is fine up
  /// to twenty lanes or so and hopeless after it, which is why the counting
  /// exists.
  static int byDriving(Parish parish, {int most = 6}) {
    if (parish.lanes.isEmpty) return 0;

    for (var allowed = 1; allowed <= most; allowed++) {
      if (_canDoItIn(parish, allowed)) return allowed;
    }
    return most + 1;
  }

  static bool _canDoItIn(Parish parish, int allowed) {
    final whole = (1 << parish.laneCount) - 1;
    final seen = <int>{};

    bool from(int here, int salted, int left) {
      if (salted == whole) return true;
      final state = (salted * parish.count + here) * (allowed + 1) + left;
      if (!seen.add(state)) return false;

      for (final lane in parish.lanesAt(here)) {
        if (salted & (1 << lane) != 0) continue;
        if (from(parish.otherEnd(lane, here), salted | (1 << lane), left)) {
          return true;
        }
      }

      // Stuck, or choosing to stop. Lift the lorry somewhere else.
      if (left <= 0) return false;
      for (var junction = 0; junction < parish.count; junction++) {
        if (junction == here) continue;
        if (from(junction, salted, left - 1)) return true;
      }
      return false;
    }

    for (var junction = 0; junction < parish.count; junction++) {
      if (parish.lanesOn(junction) == 0) continue;
      if (from(junction, 0, allowed - 1)) return true;
    }
    return false;
  }
}
