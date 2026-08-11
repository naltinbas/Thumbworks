import 'fold.dart';

/// The fewest shepherds for a fold, and the two floors under the number.
class Watch {
  const Watch({
    required this.fewest,
    required this.posted,
    required this.matching,
    required this.byLanes,
  });

  final int fewest;

  /// One set of gates that does it, as bits.
  final int posted;

  /// A biggest set of lanes no two of which share a gate. Every one of them
  /// needs its own shepherd, so the fold cannot be watched by fewer
  /// shepherds than there are lanes here. Drawn on the map, it is a floor
  /// anybody can check by eye.
  final List<int> matching;

  /// The other floor: one shepherd watches at most as many lanes as the
  /// busiest gate touches, so the lanes divided by that, rounded up, is the
  /// least that could ever do.
  final int byLanes;

  int get floor =>
      matching.length > byLanes ? matching.length : byLanes;

  bool get floorSaysSo => floor == fewest;
  bool get matchingIsTight => matching.length == fewest;
}

/// Works out the fewest shepherds, the plain way: every set of gates,
/// smallest first. Folds here are small enough that nothing cleverer earns
/// its keep, and the same is true of the matching.
class Watches {
  const Watches._();

  static Watch of(Fold fold) {
    final posted = _fewestCover(fold);
    return Watch(
      fewest: _countBits(posted),
      posted: posted,
      matching: biggestMatching(fold),
      byLanes: fold.many == 0 ? 0 : (fold.many + fold.busiest - 1) ~/ fold.busiest,
    );
  }

  static int _fewestCover(Fold fold) {
    for (var size = 0; size <= fold.count; size++) {
      final found = _coverOfSize(fold, size, 0, 0);
      if (found >= 0) return found;
    }
    return (1 << fold.count) - 1;
  }

  static int _coverOfSize(Fold fold, int size, int from, int posted) {
    if (_countBits(posted) == size) {
      return fold.watches(posted) ? posted : -1;
    }
    for (var gate = from; gate < fold.count; gate++) {
      final found =
          _coverOfSize(fold, size, gate + 1, posted | (1 << gate));
      if (found >= 0) return found;
    }
    return -1;
  }

  /// A biggest set of lanes, no two sharing a gate.
  static List<int> biggestMatching(Fold fold) {
    var best = const <int>[];

    void grow(int from, List<int> chosen, int gatesUsed) {
      if (chosen.length > best.length) best = List.of(chosen);
      for (var lane = from; lane < fold.many; lane++) {
        final ends = (1 << fold[lane].from) | (1 << fold[lane].to);
        if (gatesUsed & ends != 0) continue;
        grow(lane + 1, [...chosen, lane], gatesUsed | ends);
      }
    }

    grow(0, const [], 0);
    return best;
  }

  /// What somebody sensible does: post a shepherd at the busiest gate, strike
  /// out its lanes, and go again. It is often the fewest and not always.
  static int byGreed(Fold fold) {
    final unwatched = <int>{for (var lane = 0; lane < fold.many; lane++) lane};
    var posted = 0;

    while (unwatched.isNotEmpty) {
      var best = -1;
      var most = -1;
      for (var gate = 0; gate < fold.count; gate++) {
        if ((posted & (1 << gate)) != 0) continue;
        final here = fold
            .lanesAt(gate)
            .where(unwatched.contains)
            .length;
        if (here > most) {
          most = here;
          best = gate;
        }
      }
      if (best < 0 || most == 0) break;
      posted |= 1 << best;
      unwatched.removeWhere((lane) => fold[lane].touches(best));
    }
    return _countBits(posted);
  }

  static int _countBits(int bits) {
    var count = 0;
    var left = bits;
    while (left != 0) {
      left &= left - 1;
      count++;
    }
    return count;
  }
}
