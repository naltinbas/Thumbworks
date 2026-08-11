/// The search over every shape a block can be bitten into.
///
/// A position is the heights of the columns left standing, never rising
/// from left to right, the mouldy crumb at the bottom of the first column.
/// The mouse to bite has lost when the mouldy crumb is all that remains;
/// otherwise the position is winning exactly when some bite hands the
/// other mouse a losing one. The search memoises over shapes, which for
/// the blocks here is a few thousand at most.
///
/// The theorem the game teaches is proved here the only way it can be:
/// every whole block bigger than the mouldy crumb alone is winning for the
/// first mouse, checked block by block, because the stealing argument that
/// guarantees it names no bite. On squares and two-row strips the win has
/// a shape a player can hold: those strategies live here too, so the tests
/// can beat the search's own best resistance with them.
class Bites {
  const Bites._();

  static final _losses = <String, bool>{};
  static final _fewest = <String, int>{};

  static String _key(List<int> heights) => heights.join(',');

  /// Whether only the mouldy crumb remains.
  static bool poisonOnly(List<int> heights) {
    if (heights.isEmpty || heights[0] != 1) return false;
    for (var x = 1; x < heights.length; x++) {
      if (heights[x] != 0) return false;
    }
    return true;
  }

  /// The shape after biting at column [x], height [y].
  static List<int> bitten(List<int> heights, int x, int y) => [
        for (var column = 0; column < heights.length; column++)
          column < x ? heights[column] : (heights[column] < y ? heights[column] : y),
      ];

  /// Every legal bite: any standing crumb. The mouldy one is legal too;
  /// taking it is losing, which is the game.
  static Iterable<(int, int)> bites(List<int> heights) sync* {
    for (var x = 0; x < heights.length; x++) {
      for (var y = 0; y < heights[x]; y++) {
        yield (x, y);
      }
    }
  }

  /// Whether the mouse to bite from here loses against perfect play.
  static bool isLoss(List<int> heights) {
    if (poisonOnly(heights)) return true;
    final key = _key(heights);
    final kept = _losses[key];
    if (kept != null) return kept;

    var loss = true;
    for (final (x, y) in bites(heights)) {
      if (x == 0 && y == 0) continue;
      if (isLoss(bitten(heights, x, y))) {
        loss = false;
        break;
      }
    }
    return _losses[key] = loss;
  }

  /// The fewest bites of the winning mouse's own from a winning shape,
  /// with the loser delaying as long as it can.
  static int fewestWin(List<int> heights) {
    final key = _key(heights);
    final kept = _fewest[key];
    if (kept != null) return kept;

    var best = 1 << 20;
    for (final (x, y) in bites(heights)) {
      if (x == 0 && y == 0) continue;
      final after = bitten(heights, x, y);
      if (!isLoss(after)) continue;
      if (poisonOnly(after)) {
        best = 1;
        break;
      }
      // The loser bites something, never the mould while it has a choice,
      // and delays; then it is the winner's bite again.
      var worst = 0;
      for (final (theirX, theirY) in bites(after)) {
        if (theirX == 0 && theirY == 0) continue;
        final more = fewestWin(bitten(after, theirX, theirY));
        if (more > worst) worst = more;
      }
      if (1 + worst < best) best = 1 + worst;
    }
    return _fewest[key] = best;
  }

  /// A winning bite from a winning shape, the soonest-forcing one, or null
  /// from a losing shape.
  static (int, int)? next(List<int> heights) {
    if (isLoss(heights)) return null;
    (int, int)? best;
    var soonest = 1 << 20;
    for (final (x, y) in bites(heights)) {
      if (x == 0 && y == 0) continue;
      final after = bitten(heights, x, y);
      if (!isLoss(after)) continue;
      if (poisonOnly(after)) return (x, y);
      var worst = 0;
      for (final (theirX, theirY) in bites(after)) {
        if (theirX == 0 && theirY == 0) continue;
        final more = fewestWin(bitten(after, theirX, theirY));
        if (more > worst) worst = more;
      }
      if (1 + worst < soonest) {
        soonest = 1 + worst;
        best = (x, y);
      }
    }
    return best;
  }

  /// The grey mouse's bite: the winning one when it has it, else the
  /// longest delay, and the mould only when nothing else stands.
  static (int, int) reply(List<int> heights) {
    final winning = next(heights);
    if (winning != null) return winning;

    (int, int)? stubborn;
    var longest = -1;
    for (final (x, y) in bites(heights)) {
      if (x == 0 && y == 0) continue;
      final more = fewestWin(bitten(heights, x, y));
      if (more > longest) {
        longest = more;
        stubborn = (x, y);
      }
    }
    return stubborn ?? (0, 0);
  }

  /// The mirror strategy for squares: after the corner-nibble at (1,1),
  /// answer every bite at (x, y) with the bite at (y, x).
  static (int, int) mirrored((int, int) theirs) => (theirs.$2, theirs.$1);

  /// Whether a two-row shape has the bottom exactly one longer than the
  /// top, which is the losing shape the strip strategy hands over.
  static bool strippedShort(List<int> heights) {
    var bottom = 0, top = 0;
    for (final column in heights) {
      if (column >= 1) bottom++;
      if (column >= 2) top++;
    }
    return bottom == top + 1;
  }
}
