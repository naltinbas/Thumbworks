/// The safe squares, worked out two ways that know nothing of each other.
///
/// A square is cold when the herder who must push from it is losing: every
/// push he has lands on a hot square, from which the other herder has some
/// push back to cold, all the way down to the pen. The sweep finds them by
/// walking the field from the corner out and asking, for each square,
/// whether any push from it reaches a square already known cold.
///
/// The ladder builds the same squares with no game in sight: pair by pair,
/// take the smallest count of paces not yet used in any pair, put it with
/// itself plus the pair's number, and the two orders of each pair are the
/// cold squares. That the two constructions agree on every square of a
/// sixty-pace field is the anchor test; that the ladder is the golden
/// ratio's doing, east paces the floor of n times phi, is checked on top.
class Cold {
  const Cold._();

  static final _sweeps = <int, List<List<bool>>>{};

  /// cold[east][north] for every square within [size] paces, by the sweep.
  static List<List<bool>> sweep(int size) => _sweeps.putIfAbsent(size, () {
        final cold = [
          for (var east = 0; east <= size; east++)
            List<bool>.filled(size + 1, false),
        ];
        for (var east = 0; east <= size; east++) {
          for (var north = 0; north <= size; north++) {
            cold[east][north] = !_reachesCold(cold, east, north);
          }
        }
        return cold;
      });

  static bool _reachesCold(List<List<bool>> cold, int east, int north) {
    for (var paces = 1; paces <= east; paces++) {
      if (cold[east - paces][north]) return true;
    }
    for (var paces = 1; paces <= north; paces++) {
      if (cold[east][north - paces]) return true;
    }
    final most = east < north ? east : north;
    for (var paces = 1; paces <= most; paces++) {
      if (cold[east - paces][north - paces]) return true;
    }
    return false;
  }

  /// Whether the ewe on this square leaves the herder who must push losing.
  static bool isCold(int east, int north) {
    final size = east > north ? east : north;
    var swept = 64;
    while (swept < size) {
      swept *= 2;
    }
    return sweep(swept)[east][north];
  }

  /// The cold squares within [size] paces, built by the ladder instead: for
  /// each rung the smallest unused count of paces, paired with itself plus
  /// the rung's number, in both orders.
  static Set<(int, int)> ladder(int size) {
    final rungs = {(0, 0)};
    final used = <int>{0};
    for (var rung = 1; rung <= size; rung++) {
      var smallest = 0;
      while (used.contains(smallest)) {
        smallest++;
      }
      final larger = smallest + rung;
      if (smallest > size) break;
      used.add(smallest);
      used.add(larger);
      if (larger <= size) {
        rungs.add((smallest, larger));
        rungs.add((larger, smallest));
      }
    }
    return rungs;
  }

  /// The fewest pushes of the winning herder's own that force the pen from
  /// here, with the loser giving all the ground he can. Null when the square
  /// is cold and the herder to push cannot win at all.
  static int? fewestFrom(int east, int north) {
    if (isCold(east, north)) return null;
    return _fewest(east, north, <(int, int), int>{});
  }

  static int _fewest(int east, int north, Map<(int, int), int> seen) {
    // From a hot square: push to the pen if it is reachable cold, else to
    // the cold square whose delaying answers are shortest.
    final kept = seen[(east, north)];
    if (kept != null) return kept;

    var best = 1 << 20;
    for (final (coldEast, coldNorth) in _coldPushes(east, north)) {
      if (coldEast == 0 && coldNorth == 0) {
        best = 1;
        break;
      }
      // The loser pushes from cold to some hot square, delaying as long as
      // he can; then it is the winner's push again.
      var worst = 0;
      for (final (hotEast, hotNorth) in _pushes(coldEast, coldNorth)) {
        final more = _fewest(hotEast, hotNorth, seen);
        if (more > worst) worst = more;
      }
      if (1 + worst < best) best = 1 + worst;
    }
    return seen[(east, north)] = best;
  }

  static Iterable<(int, int)> _pushes(int east, int north) sync* {
    for (var paces = 1; paces <= east; paces++) {
      yield (east - paces, north);
    }
    for (var paces = 1; paces <= north; paces++) {
      yield (east, north - paces);
    }
    final most = east < north ? east : north;
    for (var paces = 1; paces <= most; paces++) {
      yield (east - paces, north - paces);
    }
  }

  static Iterable<(int, int)> _coldPushes(int east, int north) sync* {
    for (final square in _pushes(east, north)) {
      if (isCold(square.$1, square.$2)) yield square;
    }
  }

  /// A winning push from a hot square: to the pen when it can be, else to
  /// the cold square that ends it soonest. Null from cold squares.
  static (int, int)? next(int east, int north) {
    if (isCold(east, north)) return null;
    (int, int)? best;
    var soonest = 1 << 20;
    for (final square in _coldPushes(east, north)) {
      if (square == (0, 0)) return square;
      var worst = 0;
      for (final (hotEast, hotNorth) in _pushes(square.$1, square.$2)) {
        final more = _fewest(hotEast, hotNorth, <(int, int), int>{});
        if (more > worst) worst = more;
      }
      if (1 + worst < soonest) {
        soonest = 1 + worst;
        best = square;
      }
    }
    return best;
  }

  /// The pinder's own push. From hot he takes the win; from cold he gives
  /// the most ground he can, the push whose winning answer is longest.
  static (int, int) reply(int east, int north) {
    final winning = next(east, north);
    if (winning != null) return winning;

    (int, int)? stubborn;
    var longest = -1;
    for (final square in _pushes(east, north)) {
      final more = _fewest(square.$1, square.$2, <(int, int), int>{});
      if (more > longest) {
        longest = more;
        stubborn = square;
      }
    }
    return stubborn!;
  }
}
