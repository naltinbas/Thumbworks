import 'tower.dart';

/// Whether a peal part rung can still become the extent, and what to ring
/// next.
///
/// The extent is every row once and rounds again at the end. Whether it can
/// still be finished from part way is a search over ways of walking the rows
/// not yet rung, which on three or four bells is small enough to ask after
/// every pull, and the search remembers one full answer to hand out change
/// by change.
class Extent {
  Extent(this.tower, {int? goalRows}) : goal = goalRows ?? tower.rows;

  final Tower tower;

  /// How many rows the peal must sound, rounds among them.
  final int goal;

  /// Positions known to be dead: from this row with this set rung, the peal
  /// cannot be finished. Remembering them keeps the live check quick.
  final _dead = <String, bool>{};

  /// Whether, standing at [at] with [rung] rows already sounded, every row
  /// not yet rung can still be visited once and rounds reached at the end.
  /// [rung] holds packed keys and includes [at].
  bool canFinish(BellRow at, Set<int> rung) => _finish(at, rung) != null;

  /// The changes that finish the extent from here, or null.
  List<Change>? _finish(BellRow at, Set<int> rung) {
    final key = '${tower.keyOf(at)}:${(rung.toList()..sort()).join(',')}';
    if (_dead[key] ?? false) return null;

    final leftToRing = goal - rung.length;

    if (leftToRing == 0) {
      // Every row has sounded; the peal ends when one more change brings
      // rounds, which does not sound again, it strikes home.
      for (final change in tower.changes) {
        final next = change.apply(at);
        if (tower.keyOf(next) == tower.keyOf(tower.rounds)) {
          return [change];
        }
      }
      return null;
    }

    for (final change in tower.changes) {
      final next = change.apply(at);
      final key = tower.keyOf(next);
      if (rung.contains(key)) continue;
      if (key == tower.keyOf(tower.rounds)) continue;

      rung.add(key);
      final rest = _finish(next, rung);
      rung.remove(key);
      if (rest != null) return [change, ...rest];
    }
    _dead[key] = true;
    return null;
  }

  /// A change that keeps the extent alive from here, or null when none does.
  Change? nextFrom(BellRow at, Set<int> rung) {
    final way = _finish(at, Set.of(rung));
    return way?.first;
  }

  /// Every full extent from rounds, counted. Small towers only; it is the
  /// figure the tests pin.
  int countExtents() {
    var found = 0;

    void walk(BellRow at, Set<int> rung) {
      if (rung.length == goal) {
        for (final change in tower.changes) {
          if (tower.keyOf(change.apply(at)) == tower.keyOf(tower.rounds)) {
            found++;
          }
        }
        return;
      }
      for (final change in tower.changes) {
        final next = change.apply(at);
        final key = tower.keyOf(next);
        if (rung.contains(key)) continue;
        if (key == tower.keyOf(tower.rounds)) continue;
        rung.add(key);
        walk(next, rung);
        rung.remove(key);
      }
    }

    walk(tower.rounds, {tower.keyOf(tower.rounds)});
    return found;
  }
}
