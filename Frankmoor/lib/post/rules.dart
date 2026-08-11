/// The two answers: the remainder walk, and the plain sweep.
///
/// The post office sells two stamps only, coprime in value. An amount is
/// payable when some count of the dearer stamp leaves a remainder the
/// cheaper one divides. Since only remainders matter, at most as many
/// cases as the cheap stamp's value need checking, which is a proof a
/// customer can do at the counter.
///
/// The old results say more: with stamps a and b, the largest unpayable
/// amount is ab minus a minus b, and exactly (a-1)(b-1)/2 amounts are
/// unpayable in all. The sweep checks both by brute force, and the walk
/// and the sweep agree amount by amount.
class Rules {
  const Rules._();

  /// Whether [amount] can be paid with stamps of [cheap] and [dear],
  /// by walking the dear counts through one full remainder cycle.
  static bool payable(int amount, int cheap, int dear) {
    for (var dears = 0; dears * dear <= amount && dears < cheap; dears++) {
      if ((amount - dears * dear) % cheap == 0) return true;
    }
    return false;
  }

  /// The counts that pay [amount] exactly, fewest dear stamps first, or
  /// null: (cheap count, dear count).
  static (int, int)? paying(int amount, int cheap, int dear) {
    for (var dears = 0; dears * dear <= amount; dears++) {
      if ((amount - dears * dear) % cheap == 0) {
        return ((amount - dears * dear) ~/ cheap, dears);
      }
    }
    return null;
  }

  /// The largest unpayable amount, by the old rule.
  static int frobenius(int cheap, int dear) => cheap * dear - cheap - dear;

  /// The largest unpayable amount, by sweeping: the last gap below the
  /// rule's bound plus a margin.
  static int frobeniusBySweep(int cheap, int dear) {
    var last = -1;
    for (var amount = 1; amount <= cheap * dear; amount++) {
      if (!payable(amount, cheap, dear)) last = amount;
    }
    return last;
  }

  /// How many amounts can never be paid, by the old rule.
  static int gaps(int cheap, int dear) => (cheap - 1) * (dear - 1) ~/ 2;

  /// The same, by sweeping.
  static int gapsBySweep(int cheap, int dear) {
    var count = 0;
    for (var amount = 1; amount <= cheap * dear; amount++) {
      if (!payable(amount, cheap, dear)) count++;
    }
    return count;
  }

  /// The remainder walk for the why: the amounts left after nought, one,
  /// two ... dear stamps, one full cycle or until the amount runs out.
  static List<int> walk(int amount, int cheap, int dear) => [
        for (var dears = 0;
            dears * dear <= amount && dears < cheap;
            dears++)
          amount - dears * dear,
      ];
}
