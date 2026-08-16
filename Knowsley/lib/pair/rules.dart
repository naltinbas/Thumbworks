/// Two whole numbers, x and y, with 2 <= x < y and x + y <= 100. S is
/// told their sum and P their product, and they speak: P says he does
/// not know the numbers, S says she knew he did not, P says now he does,
/// and S says now she does too. Freudenthal set the puzzle in 1969, and
/// one pair fits: 4 and 13.
class Rules {
  static const least = 2, mostSum = 100;

  /// Every pair (x, y), x ascending then y.
  static final pairs = <(int, int)>[
    for (var x = least; x + x + 1 <= mostSum; x++)
      for (var y = x + 1; x + y <= mostSum; y++) (x, y),
  ];

  static int get count => pairs.length;

  static bool valid(int x, int y) => x >= least && x < y && x + y <= mostSum;

  /// The pairs with product [p]: what P could be looking at.
  static List<(int, int)> splitsOfProduct(int p) => [
        for (var x = least; x * x < p; x++)
          if (p % x == 0 && valid(x, p ~/ x)) (x, p ~/ x),
      ];

  /// The pairs with sum [s]: what S could be looking at.
  static List<(int, int)> splitsOfSum(int s) => [
        for (var x = least; x + x < s; x++)
          if (valid(x, s - x)) (x, s - x),
      ];

  /// P does not know: the product splits more than one way.
  static bool pInDark(int p) => splitsOfProduct(p).length > 1;

  /// S knew P did not know: every split of the sum leaves P in the dark.
  static bool sKnewDark(int s) {
    final splits = splitsOfSum(s);
    return splits.isNotEmpty && splits.every((q) => pInDark(q.$1 * q.$2));
  }

  /// P now knows: of the splits of the product, exactly one has a sum
  /// S could have spoken for.
  static bool pNowKnows(int p) => splitsOfProduct(p).where((q) => sKnewDark(q.$1 + q.$2)).length == 1;

  /// S now knows: of the splits of the sum, exactly one has a product P
  /// could now know from.
  static bool sNowKnows(int s) => splitsOfSum(s).where((q) => pInDark(q.$1 * q.$2) && pNowKnows(q.$1 * q.$2)).length == 1;

  /// The four things said, as they stand for the pair: P in the dark, S
  /// knew it, P now knows, S now knows.
  static (bool, bool, bool, bool) said(int x, int y) {
    final s = x + y, p = x * y;
    final one = pInDark(p);
    final two = one && sKnewDark(s);
    final three = two && pNowKnows(p);
    final four = three && sNowKnows(s);
    return (one, two, three, four);
  }

  /// The sums S could speak for: those where every split leaves P in the
  /// dark.
  static List<int> get speakingSums => [for (var s = 2 * least + 1; s <= mostSum; s++) if (sKnewDark(s)) s];

  /// The pairs left after each thing said, by narrowing the whole set
  /// four times: the second voice.
  static List<Set<(int, int)>> get narrowed {
    var left = pairs.toSet();
    final out = <Set<(int, int)>>[];
    // P does not know: his product is shared by another pair still in.
    Map<int, int> byProduct(Set<(int, int)> set) {
      final m = <int, int>{};
      for (final (x, y) in set) {
        m[x * y] = (m[x * y] ?? 0) + 1;
      }
      return m;
    }

    Map<int, int> bySum(Set<(int, int)> set) {
      final m = <int, int>{};
      for (final (x, y) in set) {
        m[x + y] = (m[x + y] ?? 0) + 1;
      }
      return m;
    }

    final all = pairs.toSet();
    final products = byProduct(all);
    final one = {for (final q in all) if (products[q.$1 * q.$2]! > 1) q};
    // S knew: every pair with her sum is among those where P is in the dark.
    final sumsAll = bySum(all), sumsOne = bySum(one);
    final two = {for (final q in one) if (sumsOne[q.$1 + q.$2] == sumsAll[q.$1 + q.$2]) q};
    // P now knows: his product is held by one pair of those left.
    final productsTwo = byProduct(two);
    final three = {for (final q in two) if (productsTwo[q.$1 * q.$2] == 1) q};
    // S now knows: her sum is held by one pair of those left.
    final sumsThree = bySum(three);
    final four = {for (final q in three) if (sumsThree[q.$1 + q.$2] == 1) q};
    out.addAll([one, two, three, four]);
    left = four;
    assert(left.isNotEmpty);
    return out;
  }

  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  /// Two different primes adding to [s], the smaller first, or null.
  static (int, int)? primeSplit(int s) {
    for (var p = 2; p + p < s; p++) {
      if (isPrime(p) && isPrime(s - p)) return (p, s - p);
    }
    return null;
  }

  static String tell((int, int) q) => '${q.$1} and ${q.$2}';
}
