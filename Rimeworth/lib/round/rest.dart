import 'parish.dart';

/// What is left to salt, and what finishing it will cost from here.
class Rest {
  const Rest({
    required this.runsLeft,
    required this.odd,
    required this.canGoOn,
  });

  /// How many more times the lorry has to be set down, not counting the run
  /// it is on now.
  final int runsLeft;

  /// The junctions with an odd number of unsalted lanes on them. These are
  /// where the runs still to come have to start and finish.
  final List<int> odd;

  /// Whether there is an unsalted lane where the lorry stands.
  final bool canGoOn;
}

/// Works out what is left of a parish part way through.
///
/// The same counting as at the start, done on the lanes that have not been
/// salted, with one extra thing to allow for: the lorry is already standing
/// somewhere, and wherever that is has to be an end of the run it is on.
///
/// So a piece of the parish with 2k odd junctions costs k runs, except that
/// the piece the lorry is standing in costs k+1 when the lorry is standing on
/// an even junction, because being made an end of a run is what an even
/// junction cannot do for free. A piece where every junction is even costs one
/// run, which comes back to where it set off.
class Rests {
  const Rests._();

  static Rest from(Parish parish, Set<int> salted, int at) {
    final left = [
      for (var lane = 0; lane < parish.laneCount; lane++)
        if (!salted.contains(lane)) lane,
    ];
    if (left.isEmpty) {
      return const Rest(runsLeft: 0, odd: [], canGoOn: false);
    }

    final on = List.filled(parish.count, 0);
    for (final lane in left) {
      on[parish.lanes[lane].from]++;
      on[parish.lanes[lane].to]++;
    }

    final odd = [
      for (var junction = 0; junction < parish.count; junction++)
        if (on[junction].isOdd) junction,
    ];

    // Each piece of what is left that still has a lane in it, and the odd
    // junctions in that piece.
    var cost = 0;
    var here = false;
    final seen = <int>{};
    for (final start in left.map((lane) => parish.lanes[lane].from)) {
      if (!seen.add(start)) continue;

      final piece = <int>[start];
      final waiting = <int>[start];
      while (waiting.isNotEmpty) {
        final junction = waiting.removeLast();
        for (final lane in parish.lanesAt(junction)) {
          if (salted.contains(lane)) continue;
          final there = parish.otherEnd(lane, junction);
          if (seen.add(there)) {
            piece.add(there);
            waiting.add(there);
          }
        }
      }

      final oddHere = piece.where((junction) => on[junction].isOdd).length;
      final standingHere = piece.contains(at);
      if (standingHere) here = true;

      if (oddHere == 0) {
        cost += 1;
      } else if (standingHere && on[at].isEven) {
        cost += oddHere ~/ 2 + 1;
      } else {
        cost += oddHere ~/ 2;
      }
    }

    // The run the lorry is on now is already paid for, but only if there is
    // something left where it stands to spend it on.
    return Rest(
      runsLeft: here && on[at] > 0 ? cost - 1 : cost,
      odd: odd,
      canGoOn: at >= 0 && on[at] > 0,
    );
  }
}
