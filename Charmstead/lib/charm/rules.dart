/// The law of the charm.
///
/// Nine coins, one to nine, laid on a three-by-three bed. The charm
/// holds when every row, every column and both crossways count
/// fifteen: eight lines, one answer each.
///
/// What must be is known two ways that share nothing: the counting,
/// which forces the fifteen and the middle coin, and a sweep of every
/// filling there is, which finds the charms outright.
class Rules {
  /// The eight lines, as cell indexes row-major.
  static const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  /// Whether a full laying holds the charm.
  static bool holds(List<int> laid) {
    for (final line in lines) {
      if (laid[line[0]] + laid[line[1]] + laid[line[2]] != 15) {
        return false;
      }
    }
    return true;
  }

  /// Every charm there is, swept from every filling of the bed.
  static List<List<int>> allCharms() {
    final coins = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    final found = <List<int>>[];
    _lay(coins, 0, found);
    return found;
  }

  static void _lay(List<int> coins, int from, List<List<int>> found) {
    if (from == coins.length) {
      if (holds(coins)) found.add([...coins]);
      return;
    }
    for (var at = from; at < coins.length; at++) {
      var swap = coins[from];
      coins[from] = coins[at];
      coins[at] = swap;
      // Prune: a finished line must already count fifteen.
      var fine = true;
      for (final line in lines) {
        if (line[2] > from) continue;
        if (coins[line[0]] + coins[line[1]] + coins[line[2]] != 15) {
          fine = false;
          break;
        }
      }
      if (fine) _lay(coins, from + 1, found);
      swap = coins[from];
      coins[from] = coins[at];
      coins[at] = swap;
    }
  }

  /// The charms honouring pins: cell to coin, absent cells free.
  static List<List<int>> charmsUnder(Map<int, int> pins) => [
        for (final charm in allCharms())
          if (pins.entries
              .every((pin) => charm[pin.key] == pin.value))
            charm,
      ];

  /// The one square, eight ways round: the turnings and mirrorings of
  /// any charm, as cell re-orderings.
  static const turnings = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8],
    [6, 3, 0, 7, 4, 1, 8, 5, 2],
    [8, 7, 6, 5, 4, 3, 2, 1, 0],
    [2, 5, 8, 1, 4, 7, 0, 3, 6],
    [2, 1, 0, 5, 4, 3, 8, 7, 6],
    [0, 3, 6, 1, 4, 7, 2, 5, 8],
    [6, 7, 8, 3, 4, 5, 0, 1, 2],
    [8, 5, 2, 7, 4, 1, 6, 3, 0],
  ];

  static List<int> turned(List<int> charm, List<int> turning) => [
        for (final at in turning) charm[at],
      ];
}
