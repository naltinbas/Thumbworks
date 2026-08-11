/// The hoard, the cap, and the two answers.
///
/// A pile of hazelnuts between two squirrels. The opener may take any
/// number but not the whole hoard; after that, each may take from one nut
/// up to twice what the other just took. Whoever takes the last nut has
/// the hoard.
///
/// The search settles every standing the slow way: a standing is lost
/// when every allowed take hands the other squirrel a win, memoised over
/// the pair of nuts left and nuts allowed.
///
/// The split is the strange answer. Every count of nuts breaks uniquely
/// into Fibonacci clusters no two of which are neighbours in the
/// Fibonacci run, the Zeckendorf way, greedily biggest first. The rule:
/// a standing is winning exactly when the smallest cluster is within the
/// cap, and taking exactly that cluster is the move. The anchor holds
/// rule against search on every standing to sixty nuts.
class Rules {
  const Rules._();

  static final _memo = <int, bool>{};

  /// The Fibonacci run: 1, 2, 3, 5, 8, ...
  static List<int> fibsTo(int most) {
    final fibs = [1, 2];
    while (fibs.last < most) {
      fibs.add(fibs[fibs.length - 1] + fibs[fibs.length - 2]);
    }
    return fibs;
  }

  /// The Zeckendorf split of [nuts], biggest cluster first.
  static List<int> split(int nuts) {
    final out = <int>[];
    var left = nuts;
    final fibs = fibsTo(nuts);
    for (var at = fibs.length - 1; at >= 0 && left > 0; at--) {
      if (fibs[at] <= left) {
        out.add(fibs[at]);
        left -= fibs[at];
      }
    }
    return out;
  }

  /// Whether the squirrel to move, allowed up to [cap], loses [nuts]
  /// against perfect play. By the search.
  static bool isLoss(int nuts, int cap) {
    if (nuts == 0) return true;
    final allowed = cap < nuts ? cap : nuts;
    final key = nuts * 128 + allowed;
    final kept = _memo[key];
    if (kept != null) return kept;

    var loss = true;
    for (var take = 1; take <= allowed; take++) {
      if (take == nuts || isLoss(nuts - take, 2 * take)) {
        loss = false;
        break;
      }
    }
    return _memo[key] = loss;
  }

  /// Whether the squirrel to move loses, by the split: lost exactly when
  /// the smallest cluster is out of reach.
  static bool isLossBySplit(int nuts, int cap) {
    if (nuts == 0) return true;
    return split(nuts).last > cap;
  }

  /// The winning take, or nought from a lost standing: the smallest
  /// cluster of the split, when the cap allows it.
  static int winningTake(int nuts, int cap) {
    if (nuts == 0) return 0;
    final smallest = split(nuts).last;
    if (smallest > cap) return 0;
    return smallest;
  }

  /// The stubborn take from a lost standing: the largest that does not
  /// hand the win over faster... every take loses, so take one, keeping
  /// the hoard long and the cap tight.
  static int stubbornTake(int nuts, int cap) => 1;
}
