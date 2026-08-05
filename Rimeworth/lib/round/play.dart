import 'parish.dart';
import 'rest.dart';
import 'runs.dart';

/// One thing the lorry did: set off from a junction, or drive down a lane.
class Move {
  const Move.setOff(this.junction) : lane = -1;
  const Move.drive(this.lane, this.junction);

  /// The lane it went down, or -1 when it was set down rather than driven.
  final int lane;

  /// Where the lorry ended up.
  final int junction;

  bool get isSetOff => lane < 0;
}

/// A parish part way through: where the lorry is and what it has salted.
///
/// The lorry is set down at a junction, and after that it drives. When there
/// is nothing left to salt where it stands, the next junction tapped is a new
/// run and costs one. It is never lifted while it can still drive, and it
/// loses nothing by that: whatever the best way of finishing from here is,
/// there is one just as good that goes on driving.
class Play {
  Play._(this.parish, this.moves);

  factory Play.of(Parish parish) => Play._(parish, const []);

  final Parish parish;

  /// Everything the lorry has done, in order.
  final List<Move> moves;

  /// Where the lorry stands, or -1 before it has been set down.
  int get at => moves.isEmpty ? -1 : moves.last.junction;

  /// How many times it has been set down.
  int get runs => moves.where((move) => move.isSetOff).length;

  /// The lanes that have been salted, in the order they were.
  List<int> get salted => [
        for (final move in moves)
          if (!move.isSetOff) move.lane,
      ];

  Set<int> get saltedSet => salted.toSet();

  int get done => moves.length - runs;

  bool get isDone => done == parish.laneCount;

  /// Whether there is anywhere left to drive from where the lorry stands.
  bool get isStuck {
    if (at < 0 || isDone) return false;
    final salted = saltedSet;
    return !parish.lanesAt(at).any((lane) => !salted.contains(lane));
  }

  /// What is left, and what finishing it will cost from here.
  Rest get rest => Rests.from(parish, saltedSet, at);

  /// The fewest runs this could still finish in, counting the ones already
  /// set off on.
  int get couldFinishIn => runs + rest.runsLeft;

  /// The lane between where the lorry stands and a junction, if it can still
  /// be driven. Otherwise -1.
  int laneTo(int junction) {
    if (at < 0) return -1;
    final salted = saltedSet;
    for (final lane in parish.lanesAt(at)) {
      if (salted.contains(lane)) continue;
      if (parish.otherEnd(lane, at) == junction) return lane;
    }
    return -1;
  }

  bool _hasLaneLeft(int junction) {
    final salted = saltedSet;
    return parish.lanesAt(junction).any((lane) => !salted.contains(lane));
  }

  /// Drives the lorry to a junction, or sets it down there. Gives back the
  /// parish afterwards, or this one when the tap was on somewhere it cannot
  /// go.
  Play touch(int junction) {
    if (isDone || junction < 0 || junction >= parish.count) return this;

    if (at >= 0) {
      final lane = laneTo(junction);
      if (lane >= 0) {
        return Play._(parish, [...moves, Move.drive(lane, junction)]);
      }
      if (!isStuck) return this;
    }

    if (!_hasLaneLeft(junction)) return this;
    return Play._(parish, [...moves, Move.setOff(junction)]);
  }

  bool get canTakeBack => moves.isNotEmpty;

  Play get back => moves.isEmpty
      ? this
      : Play._(parish, moves.sublist(0, moves.length - 1));

  Play get again => Play.of(parish);

  /// Asked. The junction to head for next that still finishes in as few runs
  /// as the parish can now be finished in.
  ///
  /// Every lane out of where the lorry stands is tried and the rest of the
  /// parish counted up after each one, which is the same counting the game
  /// does after every move rather than a route worked out in advance and read
  /// off. When there is nothing left where the lorry stands, it is a junction
  /// to set off again from instead.
  int? get next {
    if (isDone) return null;

    if (at < 0 || isStuck) {
      final rest = this.rest;
      if (rest.odd.isNotEmpty) return rest.odd.first;
      for (var junction = 0; junction < parish.count; junction++) {
        if (junction != at && _hasLaneLeft(junction)) return junction;
      }
      return null;
    }

    final salted = saltedSet;
    var best = -1;
    var cost = 1 << 30;
    for (final lane in parish.lanesAt(at)) {
      if (salted.contains(lane)) continue;
      final there = parish.otherEnd(lane, at);
      final after = touch(there).rest.runsLeft;
      if (after < cost) {
        cost = after;
        best = there;
      }
    }
    return best < 0 ? null : best;
  }

  /// What the parish takes at best, worked out once at the start.
  Round get round => Runs.fewestFor(parish);
}
