import 'yard.dart';

/// What a search found.
class Haul {
  const Haul({required this.pushes, required this.line, required this.looked});

  /// The fewest shoves that finish the yard, or null if nothing does.
  final int? pushes;

  /// One shortest way to do it, shove by shove. Empty if there is none.
  final List<Shove> line;

  /// How many positions were looked at. Only for the tools.
  final int looked;

  bool get canBeDone => pushes != null;
}

/// Works out the fewest shoves a yard can be finished in.
///
/// Searches over shoves rather than over steps. Walking about is free — it
/// cannot make a yard worse — so the only thing worth counting, and the only
/// thing worth searching over, is where the crates go.
///
/// Two positions count as the same when the crates match and the hauler is
/// shut in the same pocket by them. That is not an approximation: with the
/// same crates and the hauler anywhere in the same pocket, exactly the same
/// shoves are possible.
class Hauler {
  Hauler(this.ground) : _live = _liveSquares(ground);

  final Ground ground;

  /// Squares a crate could still be shoved to a mark from, if it were the only
  /// crate in the yard. A crate anywhere else is already lost, and so is the
  /// yard.
  final Set<int> _live;

  Set<int> get live => _live;

  /// How many positions a search will look at before giving up.
  ///
  /// A search that has to say "no" looks at every position there is, so this
  /// is the cost of the answer nobody wants. The yards here are small enough
  /// that it is never reached; a yard that reaches it is too big to be told
  /// honestly whether it is finished.
  static const mostLooked = 400000;

  Haul from(Yard start) {
    if (start.isDone) {
      return const Haul(pushes: 0, line: [], looked: 0);
    }
    if (isLostAt(start, start.crates)) {
      return const Haul(pushes: null, line: [], looked: 0);
    }

    final seen = <String>{start.sameness};
    // Each entry is a position and how it was reached, so the way back out is
    // a walk up the list rather than a second search.
    final queue = <Yard>[start];
    final cameFrom = <int>[-1];
    final byShove = <Shove?>[null];
    var head = 0;
    var looked = 0;

    while (head < queue.length) {
      final here = queue[head];
      final at = head;
      head++;

      for (final crate in here.crates) {
        for (final way in Way.values) {
          final stand = ground.beyond(crate, way.back);
          final onto = ground.beyond(crate, way);
          if (stand < 0 || onto < 0) continue;
          if (!here.canReach(stand)) continue;
          if (here.hasCrate(onto)) continue;
          if (!_live.contains(onto)) continue;

          final next = here.withHauler(stand).step(way)!;
          // Only the crate that just moved can have made the position
          // hopeless: every other crate stood where it stands now a moment
          // ago, when the position was still winnable.
          if (isLostAt(next, [next.moved!])) continue;
          if (!seen.add(next.sameness)) continue;

          if (next.isDone) {
            final line = <Shove>[Shove(crate, way)];
            var back = at;
            while (back > 0) {
              line.insert(0, byShove[back]!);
              back = cameFrom[back];
            }
            return Haul(pushes: line.length, line: line, looked: looked);
          }

          queue.add(next);
          cameFrom.add(at);
          byShove.add(Shove(crate, way));
          if (++looked >= mostLooked) {
            return Haul(pushes: null, line: const [], looked: looked);
          }
        }
      }
    }
    return Haul(pushes: null, line: const [], looked: looked);
  }

  /// Whether this position is already lost, without searching.
  ///
  /// Two cheap checks that between them catch nearly every mistake as it is
  /// made: a crate on a square nothing can be shoved out of towards a mark,
  /// and a block of four squares that are all crate or wall — nothing in such
  /// a block can ever move again.
  ///
  /// [which] is the crates worth looking at. After a shove that is the one
  /// crate that moved, and nothing else can have changed.
  bool isLostAt(Yard yard, Iterable<int> which) {
    for (final crate in which) {
      if (!_live.contains(crate)) return true;
    }
    return _hasFrozenBlock(yard, which);
  }

  bool _hasFrozenBlock(Yard yard, Iterable<int> which) {
    bool solid(int at) => at < 0 || yard.hasCrate(at);

    for (final crate in which) {
      if (ground.isMark(crate)) continue;
      for (final corner in const [
        [Way.up, Way.left],
        [Way.up, Way.right],
        [Way.down, Way.left],
        [Way.down, Way.right],
      ]) {
        final side = ground.beyond(crate, corner[0]);
        final other = ground.beyond(crate, corner[1]);
        if (!solid(side) || !solid(other)) continue;
        if (side < 0 || solid(ground.beyond(side, corner[1]))) return true;
      }
    }
    return false;
  }

  /// The squares a crate could reach a mark from.
  ///
  /// Worked out backwards: a mark is one, and any square a crate could have
  /// been shoved into a known one from is one too — which needs room for the
  /// crate and room behind it for whoever shoved it.
  static Set<int> _liveSquares(Ground ground) {
    final live = <int>{...ground.marks};
    final todo = [...ground.marks];
    while (todo.isNotEmpty) {
      final here = todo.removeLast();
      for (final way in Way.values) {
        final from = ground.beyond(here, way.back);
        if (from < 0) continue;
        if (ground.beyond(from, way.back) < 0) continue;
        if (live.add(from)) todo.add(from);
      }
    }
    return live;
  }
}
