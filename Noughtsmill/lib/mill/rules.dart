/// The law of the mill.
///
/// Wind the mill to n and it grinds n factorial; the count that
/// matters is the noughts on the end. Legendre's ledger totals
/// them without grinding: n over 5, plus n over 25, plus n over
/// 125, each rounded down, since every trailing nought needs a
/// five and the twos come free.
///
/// The counts climb in runs of five and skip a value at every
/// twenty-five, where a single winding brings two fives at
/// once: no winding anywhere ends in exactly five noughts. The
/// suite grinds the factorials whole, sums the ledger, and
/// refuses the bake the moment the two part ways.
class Rules {
  /// The furthest the mill winds.
  static const most = 200;

  /// Legendre's ledger: the terms n over each power of five.
  static List<int> ledger(int wound) {
    final terms = <int>[];
    var power = 5;
    while (power <= wound) {
      terms.add(wound ~/ power);
      power *= 5;
    }
    return terms;
  }

  /// The noughts by the ledger.
  static int noughts(int wound) =>
      ledger(wound).fold(0, (sum, term) => sum + term);

  /// The noughts by grinding: the factorial itself, trailed.
  static int ground(int wound) {
    var mill = BigInt.one;
    for (var turn = 2; turn <= wound; turn++) {
      mill *= BigInt.from(turn);
    }
    var count = 0;
    final ten = BigInt.from(10);
    while (wound > 0 && mill % ten == BigInt.zero) {
      count++;
      mill = mill ~/ ten;
    }
    return count;
  }

  /// Every winding landing exactly [asked] noughts, to the
  /// mill's furthest.
  static List<int> windings(int asked) => [
        for (var wound = 0; wound <= most; wound++)
          if (noughts(wound) == asked) wound,
      ];

  /// The counts no winding reaches, up to [past].
  static List<int> skipped(int past) {
    final reached = <int>{
      for (var wound = 0; wound <= most; wound++)
        noughts(wound),
    };
    return [
      for (var count = 0; count <= past; count++)
        if (!reached.contains(count)) count,
    ];
  }

  /// Whether the ledger and the grinding agree to the mill's
  /// furthest, the runs come five long, and the skips fall six
  /// apart.
  static bool lawHolds() {
    for (var wound = 0; wound <= most; wound++) {
      if (noughts(wound) != ground(wound)) return false;
    }
    // Every reached count below the top is reached exactly five
    // times.
    final counted = <int, int>{};
    for (var wound = 0; wound <= most; wound++) {
      counted[noughts(wound)] =
          (counted[noughts(wound)] ?? 0) + 1;
    }
    final top = noughts(most);
    for (final held in counted.entries) {
      if (held.key == 0 || held.key >= top) continue;
      if (held.value != 5) return false;
    }
    // The skips to 29 fall at 5, 11, 17, 23, 29.
    if ('${skipped(29)}' != '[5, 11, 17, 23, 29]') return false;
    return true;
  }
}
