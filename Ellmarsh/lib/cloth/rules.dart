/// The two answers: the search, and the golden gap.
///
/// Two bolts of cloth on the bench. A cut takes any whole multiple of the
/// shorter bolt off the longer, and must take at least one; whoever cuts
/// a bolt to nothing wins the bench. The search settles every pair the
/// slow way, memoised.
///
/// The gap is the strange answer. Call the bolts long and short: the
/// cutter holds the bench exactly when long is at least the golden ratio
/// times short, and whenever short divides long outright. In whole
/// numbers, long times long against long times short plus short times
/// short: no floating point anywhere, because the golden ratio is
/// exactly the number whose square is itself plus one, scaled. Pairs
/// inside the gap have one forced cut only, so the game walks the
/// Euclidean algorithm, and choice appears exactly where a quotient is
/// two or more.
class Rules {
  const Rules._();

  static final _memo = <int, bool>{};

  /// Whether the cutter loses the pair against perfect play, by search.
  /// Order does not matter; a nought bolt means the game is already over
  /// and the mover, having no cut, has lost it.
  static bool isLoss(int one, int other) {
    final long = one > other ? one : other;
    final short = one > other ? other : one;
    if (short == 0) return true;
    final key = long * 1024 + short;
    final kept = _memo[key];
    if (kept != null) return kept;

    var loss = true;
    for (var times = 1; times * short <= long; times++) {
      if (isLoss(long - times * short, short)) {
        loss = false;
        break;
      }
    }
    return _memo[key] = loss;
  }

  /// Whether the cutter loses, by the gap: lost exactly when the long
  /// bolt is strictly between one and the golden ratio times the short.
  static bool isLossByGap(int one, int other) {
    final long = one > other ? one : other;
    final short = one > other ? other : one;
    if (short == 0) return true;
    if (long == short) return false;
    if (long % short == 0) return false;
    // long < phi * short, in whole numbers: long^2 < long*short + short^2.
    return long * long < long * short + short * short;
  }

  /// A winning cut from a winning pair: how many times the short bolt to
  /// take off the long, or nought from a lost pair.
  static int winningTimes(int one, int other) {
    final long = one > other ? one : other;
    final short = one > other ? other : one;
    if (short == 0) return 0;
    for (var times = 1; times * short <= long; times++) {
      if (isLoss(long - times * short, short)) return times;
    }
    return 0;
  }

  /// The quotient: how many whole times the short bolt fits the long.
  static int quotient(int one, int other) {
    final long = one > other ? one : other;
    final short = one > other ? other : one;
    return short == 0 ? 0 : long ~/ short;
  }
}
