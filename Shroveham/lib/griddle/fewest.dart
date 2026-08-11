/// The two answers: the walk of every batch, and the gap count.
///
/// The walk is the referee. For each batch size it breathes out every
/// arrangement reachable from the served one, a flip at a time; flips undo
/// themselves, so the distance from served to a batch is the distance from
/// the batch to served, and looking a batch up answers the live question in
/// a game.
///
/// The gap count is the floor a player can check by eye. Read the stack
/// from the griddle up with the griddle itself as a final, biggest cake;
/// every neighbouring pair whose sizes are not next to each other is a gap.
/// A flip moves one boundary, so it mends at most one gap, and a served
/// batch has none: as many flips as gaps, at least. On some batches the
/// floor is the answer; on others the walk knows one more is needed, and
/// which batches those are is part of what the game teaches.
class Flips {
  const Flips._();

  static final _walks = <int, Map<String, int>>{};

  static String _key(List<int> cakes) => cakes.join(',');

  /// Distance-from-served for every arrangement of [size] cakes.
  static Map<String, int> walk(int size) => _walks.putIfAbsent(size, () {
        final served = [for (var cake = size; cake >= 1; cake--) cake];
        final far = <String, int>{_key(served): 0};
        var edge = [served];
        var away = 0;
        while (edge.isNotEmpty) {
          away++;
          final next = <List<int>>[];
          for (final batch in edge) {
            // Under any cake but the top one alone: turning one cake over
            // changes nothing, and under the bottom cake is the whole batch.
            for (var under = 0; under <= size - 2; under++) {
              final turned = flipped(batch, under);
              final key = _key(turned);
              if (far.containsKey(key)) continue;
              far[key] = away;
              next.add(turned);
            }
          }
          edge = next;
        }
        return far;
      });

  /// The batch with everything above [under] turned over, the cake at
  /// [under] included. Cakes are listed from the griddle up, so the flip
  /// reverses the tail of the list.
  static List<int> flipped(List<int> cakes, int under) => [
        ...cakes.sublist(0, under),
        ...cakes.sublist(under).reversed,
      ];

  /// The fewest flips that serve [cakes], by the walk.
  static int byWalk(List<int> cakes) => walk(cakes.length)[_key(cakes)]!;

  /// The floor: how many neighbouring pairs, the griddle counted as one
  /// cake bigger than the biggest, are not next to each other in size.
  static int gaps(List<int> cakes) {
    var counted = 0;
    for (var at = 0; at <= cakes.length - 1; at++) {
      final below = at == 0 ? cakes.length + 1 : cakes[at - 1];
      final here = cakes[at];
      if ((below - here).abs() != 1) counted++;
    }
    return counted;
  }

  /// How many flips the griddle hand's way takes: bring the biggest cake
  /// not yet home up to the top, turn it down to its place, and so on, two
  /// flips a cake, skipping cakes already sitting right.
  static int byHand(List<int> cakes) {
    var batch = [...cakes];
    var flips = 0;
    for (var size = batch.length; size >= 1; size--) {
      final home = batch.length - size;
      final at = batch.indexOf(size);
      if (at == home) continue;
      if (at != batch.length - 1) {
        batch = flipped(batch, at);
        flips++;
      }
      batch = flipped(batch, home);
      flips++;
    }
    return flips;
  }
}
