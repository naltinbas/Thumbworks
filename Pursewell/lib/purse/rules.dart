/// The law of the purse.
///
/// The coinage runs 1, 2, 3, 5, 8, 13, 21: each coin the sum of
/// the two before it. The paying rule is Zeckendorf's: no two
/// neighbouring denominations in one payment.
///
/// The law is uniqueness, checked more ways than one: the sweep
/// tries every lawful handful of coins and finds exactly one
/// payment for every purse from one to a hundred; the greedy
/// walk, largest coin first, lands on that payment every time;
/// and the census reads any tray for neighbours and total. The
/// suite refuses the bake the moment any two part ways.
class Rules {
  /// The coins of the well, smallest first.
  static const coins = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89];

  /// The neighbouring pairs in a tray: coins standing side by
  /// side in the coinage.
  static List<(int, int)> neighbours(List<int> tray) {
    final held = tray.toSet();
    return [
      for (var at = 0; at + 1 < coins.length; at++)
        if (held.contains(coins[at]) &&
            held.contains(coins[at + 1]))
          (coins[at], coins[at + 1]),
    ];
  }

  static int total(List<int> tray) =>
      tray.fold(0, (sum, coin) => sum + coin);

  /// Whether a tray pays [price] lawfully.
  static bool pays(List<int> tray, int price) =>
      total(tray) == price && neighbours(tray).isEmpty;

  /// Every lawful payment of [price]: subsets of the coinage
  /// with no neighbours, summing exactly.
  static List<List<int>> payments(int price) {
    final found = <List<int>>[];
    void walk(int at, int left, List<int> picked) {
      if (left == 0) {
        found.add(List.of(picked));
        return;
      }
      if (at >= coins.length || coins[at] > left) return;
      walk(at + 1, left, picked);
      picked.add(coins[at]);
      walk(at + 2, left - coins[at], picked);
      picked.removeLast();
    }

    walk(0, price, []);
    return found;
  }

  /// The greedy payment: the largest coin that fits, then two
  /// steps down, until the purse is paid.
  static List<int> greedy(int price) {
    final picked = <int>[];
    var at = coins.length - 1;
    var left = price;
    while (left > 0) {
      while (coins[at] > left) {
        at--;
      }
      picked.add(coins[at]);
      left -= coins[at];
      at -= 2;
    }
    return picked.reversed.toList();
  }

  /// Whether every purse from 1 to [most] pays exactly one way,
  /// and the greedy finds it.
  static bool lawHolds({int most = 100}) {
    for (var price = 1; price <= most; price++) {
      final ways = payments(price);
      if (ways.length != 1) return false;
      final one = List.of(ways.single)..sort();
      final walked = List.of(greedy(price))..sort();
      if ('$one' != '$walked') return false;
    }
    return true;
  }
}
