/// Two rows of oxen, near and off, yoked one to one, and the pull that
/// comes of it.
///
/// A yoking pairs each ox of the near row with one of the off row. The
/// pull of a pair is the two beasts multiplied, and the pull of the
/// whole team is those added up. The near row never moves; the off row
/// is what the player swaps about.
///
/// Everything here is whole numbers, and no pull is ever worked out as
/// anything but a sum of products.
class Rules {
  /// Oxen in each row.
  static const oxen = 5;

  /// The near row, which stays as it is.
  static const near = [1, 2, 3, 4, 5];

  /// The off row, in the order it is written on the level. The player
  /// rearranges it.
  static const off = [1, 2, 3, 4, 5];

  /// The pull of a team: each near ox against the off ox yoked to it,
  /// multiplied, and the lot added.
  static int pull(List<int> order) {
    var total = 0;
    for (var i = 0; i < oxen; i++) {
      total += near[i] * off[order[i]];
    }
    return total;
  }

  /// The second voice, which yokes nobody. Sort both rows the same way
  /// and multiply them place by place: that is the hardest any team can
  /// pull. Sort them opposite ways and it is the softest. Neither
  /// needs a yoking tried.
  static int hardest() {
    final a = [...near]..sort();
    final b = [...off]..sort();
    var total = 0;
    for (var i = 0; i < oxen; i++) {
      total += a[i] * b[i];
    }
    return total;
  }

  static int softest() {
    final a = [...near]..sort();
    final b = [...off]..sort();
    var total = 0;
    for (var i = 0; i < oxen; i++) {
      total += a[i] * b[oxen - 1 - i];
    }
    return total;
  }

  /// Every yoking there is, as orders of the off row.
  static List<List<int>> yokings() {
    final out = <List<int>>[];
    void walk(List<int> so, List<bool> used) {
      if (so.length == oxen) {
        out.add([...so]);
        return;
      }
      for (var i = 0; i < oxen; i++) {
        if (used[i]) continue;
        used[i] = true;
        walk([...so, i], used);
        used[i] = false;
      }
    }

    walk(const [], List.filled(oxen, false));
    return out;
  }

  /// Whether two places are yoked the wrong way round: the stronger near
  /// ox pulling with the weaker off one. Swapping such a pair never
  /// softens the team, which is the whole of the proof and also the
  /// player's own move.
  static bool crossed(List<int> order, int i, int j) {
    final nearGap = near[i] - near[j];
    final offGap = off[order[i]] - off[order[j]];
    return nearGap * offGap < 0;
  }

  /// What swapping two places does to the pull. It comes to the near gap
  /// multiplied by the off gap, so it is never a loss when the pair was
  /// crossed and never a gain when it was not.
  static int swapGain(List<int> order, int i, int j) {
    final nearGap = near[i] - near[j];
    final offGap = off[order[j]] - off[order[i]];
    return nearGap * offGap;
  }

  /// The team with two places swapped.
  static List<int> swap(List<int> order, int i, int j) {
    final out = [...order];
    final held = out[i];
    out[i] = out[j];
    out[j] = held;
    return out;
  }

  /// The swaps between two yokings, which is five less the rings in the
  /// shuffle from one to the other.
  static int between(List<int> from, List<int> to) {
    final where = List.filled(oxen, 0);
    for (var i = 0; i < oxen; i++) {
      where[from[i]] = to[i];
    }
    final seen = List.filled(oxen, false);
    var rings = 0;
    for (var i = 0; i < oxen; i++) {
      if (seen[i]) continue;
      rings++;
      var j = i;
      while (!seen[j]) {
        seen[j] = true;
        j = where[j];
      }
    }
    return oxen - rings;
  }

  /// The yoking the team starts in: the off row turned back to front,
  /// which is the softest pull there is.
  static List<int> get opening =>
      [for (var i = oxen - 1; i >= 0; i--) i];
}
