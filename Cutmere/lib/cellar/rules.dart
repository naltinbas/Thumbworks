/// The law of the cellar: one cask of n holds the coin, a question cuts
/// the row of casks that might into two parts, left and right, and the
/// cellarman answers to keep you guessing, naming the bigger part every
/// time; when the parts are even he names the right.
class Rules {
  const Rules();

  /// The part the cellarman keeps when a row of [size] is cut after
  /// [cut] casks: (kept size, whether the right part), the bigger part
  /// and the right when even.
  static (int, bool) kept(int size, int cut) {
    final left = cut, right = size - cut;
    return right >= left ? (right, true) : (left, false);
  }

  /// The fewest questions that find the coin among [size] casks whatever
  /// the cellarman answers, by the game tree: nought for one cask, else
  /// one more than the best cut's worst part.
  static int questions(int size) {
    if (_memo.containsKey(size)) return _memo[size]!;
    if (size <= 1) return _memo[size] = 0;
    var best = size;
    for (var cut = 1; cut < size; cut++) {
      final worst = 1 + questions(cut > size - cut ? cut : size - cut);
      if (worst < best) best = worst;
    }
    return _memo[size] = best;
  }

  static final _memo = <int, int>{};

  /// The bound: [k] questions have 2 to the k answers, so they tell
  /// apart 2 to the k casks at most; the fewest that suffice for [size]
  /// is the least k with 2 to the k at least size.
  static int bound(int size) {
    var k = 0, reach = 1;
    while (reach < size) {
      reach *= 2;
      k++;
    }
    return k;
  }

  /// The first cuts of a row of [size] after which [left] questions
  /// still suffice whatever the answer: (winning cuts, all cuts).
  static (int, int) sweep(int size, int left) {
    var winning = 0;
    for (var cut = 1; cut < size; cut++) {
      final (bigger, _) = kept(size, cut);
      if (questions(bigger) <= left - 1) winning++;
    }
    return (winning, size - 1);
  }

  /// The middle cut, the one that leaves the least either way.
  static int middle(int size) => size ~/ 2;
}
