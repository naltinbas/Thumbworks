import 'yard.dart';

/// The searches, and the colour argument beside them.
///
/// A paddock is dark or light like a chessboard square, and every jump the
/// colt can make lands on the other colour. That one fact is a certificate
/// a player can check by eye: a closed round alternates colours all the
/// way and comes home, so it needs exactly as many dark paddocks as light,
/// and a yard with an odd number of paddocks can never have one. An open
/// round on an odd yard must start and end on the majority colour, because
/// a path that alternates and touches everything has one more of the
/// colour it starts on.
///
/// Where the colours have nothing to say, the search speaks: a pruned walk
/// over every way the round could continue, small enough here to be exact
/// and fast, and the tests time nothing because nothing needs timing at
/// these sizes.
class Rounds {
  const Rounds._();

  /// The eight jumps.
  static const jumps = [
    (1, 2), (2, 1), (2, -1), (1, -2),
    (-1, -2), (-2, -1), (-2, 1), (-1, 2),
  ];

  static bool dark(Yard yard, int paddock) {
    final x = paddock % yard.width;
    final y = paddock ~/ yard.width;
    return (x + y).isEven;
  }

  /// The paddocks one jump from [paddock].
  static List<int> from(Yard yard, int paddock) {
    final x = paddock % yard.width;
    final y = paddock ~/ yard.width;
    return [
      for (final (dx, dy) in jumps)
        if (x + dx >= 0 &&
            x + dx < yard.width &&
            y + dy >= 0 &&
            y + dy < yard.height)
          (y + dy) * yard.width + (x + dx),
    ];
  }

  /// Whether the round can still be finished from a part-ridden path:
  /// every unridden paddock once more, and home again when the yard asks
  /// it. The path must not be empty.
  static bool canStillRide(Yard yard, List<int> path) {
    final ridden = List<bool>.filled(yard.paddocks, false);
    for (final paddock in path) {
      ridden[paddock] = true;
    }
    final left = yard.paddocks - path.length;
    if (left == 0) {
      return !yard.closed ||
          from(yard, path.last).contains(path.first);
    }
    return _ride(yard, ridden, path.last, path.first, left);
  }

  static bool _ride(
    Yard yard,
    List<bool> ridden,
    int here,
    int home,
    int left,
  ) {
    // Pruning: every unridden paddock must keep a way in and a way out.
    // Count the unridden neighbours of each unridden paddock, treating
    // the colt's paddock as a way in, and home as a way out on closed
    // rounds. A paddock with none is stranded; two dead ends beyond the
    // last paddock cannot both be reached.
    var deadEnds = 0;
    for (var paddock = 0; paddock < yard.paddocks; paddock++) {
      if (ridden[paddock]) continue;
      var ways = 0;
      for (final near in from(yard, paddock)) {
        if (!ridden[near] || near == here) ways++;
        if (yard.closed && near == home && ridden[near]) ways++;
      }
      if (ways == 0) return false;
      if (ways == 1) deadEnds++;
      if (deadEnds > (yard.closed ? 0 : 1)) return false;
    }

    // Warnsdorff order: fewest onward ways first, which finds rides fast
    // and fails fast when there are none.
    final nexts = [
      for (final near in from(yard, here))
        if (!ridden[near]) near,
    ]..sort((a, b) => _ways(yard, ridden, a).compareTo(_ways(yard, ridden, b)));

    for (final next in nexts) {
      if (left == 1) {
        if (!yard.closed || from(yard, next).contains(home)) return true;
        continue;
      }
      ridden[next] = true;
      if (_ride(yard, ridden, next, home, left - 1)) {
        ridden[next] = false;
        return true;
      }
      ridden[next] = false;
    }
    return false;
  }

  static int _ways(Yard yard, List<bool> ridden, int paddock) {
    var ways = 0;
    for (final near in from(yard, paddock)) {
      if (!ridden[near]) ways++;
    }
    return ways;
  }

  /// Whether any full round exists on the yard, from [starts] or from
  /// anywhere.
  static bool exists(Yard yard) {
    if (yard.starts != null) {
      return canStillRide(yard, [yard.starts!]);
    }
    for (var paddock = 0; paddock < yard.paddocks; paddock++) {
      if (canStillRide(yard, [paddock])) return true;
    }
    return false;
  }
}
