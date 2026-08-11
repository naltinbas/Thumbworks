/// The two answers: the arithmetic on the seat numbers, and the search.
///
/// The arithmetic is done on the fingers. Number the seats one to 2n and
/// add them all: that is S. The two blocks of k sit at some seat p and at
/// seat p + k + 1, which together add to 2p + k + 1. Sum that over every
/// pair: twice all the p's, which is even, plus the sum of every k + 1. So
/// S minus the sum of the k + 1's must be even, and for n leaving one or
/// two when divided by four, it is odd: no setting can exist, and no
/// search is needed to know it.
///
/// The search is plain backtracking, biggest pair first, and it is the
/// referee everywhere: it finds the settings where they exist, counts
/// them, and comes back empty-handed exactly where the arithmetic says it
/// must.
class Rows {
  const Rows._();

  /// What the arithmetic says: whether the parity allows any setting.
  static bool parityAllows(int pairs) {
    final seatSum = pairs * (2 * pairs + 1); // 1 + 2 + ... + 2n
    final spanSum = pairs * (pairs + 1) ~/ 2 + pairs; // sum of k + 1
    return (seatSum - spanSum).isEven;
  }

  /// Every setting, as filled rows, biggest pair placed first. Stops
  /// early at [most] settings when asked.
  static List<List<int>> settings(int pairs, {int? most}) {
    final row = List<int>.filled(pairs * 2, 0);
    final out = <List<int>>[];
    _set(row, pairs, out, most);
    return out;
  }

  static bool _set(List<int> row, int pair, List<List<int>> out, int? most) {
    if (pair == 0) {
      out.add([...row]);
      return most != null && out.length >= most;
    }
    for (var seat = 0; seat + pair + 1 < row.length; seat++) {
      if (row[seat] != 0 || row[seat + pair + 1] != 0) continue;
      row[seat] = pair;
      row[seat + pair + 1] = pair;
      if (_set(row, pair - 1, out, most)) return true;
      row[seat] = 0;
      row[seat + pair + 1] = 0;
    }
    return false;
  }

  /// How many settings there are, mirror images counted apart.
  static int ways(int pairs) => settings(pairs).length;

  /// Whether a part-set row can still be finished: the pairs left are
  /// everything not yet on the shelf, biggest next.
  static bool canStillSet(List<int> row, int placing) {
    if (placing == 0) return true;
    for (var seat = 0; seat + placing + 1 < row.length; seat++) {
      if (row[seat] != 0 || row[seat + placing + 1] != 0) continue;
      row[seat] = placing;
      row[seat + placing + 1] = placing;
      final onward = canStillSet(row, placing - 1);
      row[seat] = 0;
      row[seat + placing + 1] = 0;
      if (onward) return true;
    }
    return false;
  }
}
