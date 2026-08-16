/// The mint's coins and the tidy rule: coins of 1, 2, 3, 5, 8, 13, 21,
/// 34, 55 and 89, one of each in the purse, each the two before it
/// added, and a picking is tidy when no two of its coins are
/// neighbours on the rack. Zeckendorf showed that every price is paid
/// tidily in exactly one way.
class Rules {
  /// The coins, smallest first: the Fibonacci numbers from 1 and 2.
  static const coins = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89];

  static int get count => coins.length;

  /// Every coin laid on the counter at once.
  static int get purse => coins.fold(0, (a, b) => a + b);

  /// The dearest price a tidy picking pays: every other coin from the
  /// top, one short of the coin the mint never struck.
  static int get tidyTop => sumOf(alternate(coins.last));

  /// The coin the mint never struck: the last two coins added.
  static int get unminted => coins[count - 1] + coins[count - 2];

  /// Where a coin sits on the rack.
  static int placeOf(int coin) => coins.indexOf(coin);

  /// Whether two coins are neighbours on the rack.
  static bool neighbours(int a, int b) => (placeOf(a) - placeOf(b)).abs() == 1;

  /// The neighbouring pairs among [picked], each once, dearer coin first.
  static List<(int, int)> neighbourPairs(Iterable<int> picked) {
    final places = picked.map(placeOf).toList()..sort((a, b) => b - a);
    return [
      for (var i = 0; i + 1 < places.length; i++)
        if (places[i] - places[i + 1] == 1) (coins[places[i]], coins[places[i + 1]]),
    ];
  }

  /// Whether no two of [picked] are neighbours.
  static bool tidy(Iterable<int> picked) => neighbourPairs(picked).isEmpty;

  static int sumOf(Iterable<int> picked) => picked.fold(0, (a, b) => a + b);

  /// Every picking of coins from the purse, as the coins picked, dearest
  /// first: 1,024 of them, the empty one among them.
  static List<List<int>> get pickings => [
        for (var mask = 0; mask < (1 << count); mask++)
          [for (var i = count - 1; i >= 0; i--) if (mask & (1 << i) != 0) coins[i]],
      ];

  /// The greedy purse: the dearest coin not over what is left, again
  /// and again, each coin once, dearest first; null when it falls short.
  static List<int>? greedy(int price) {
    final out = <int>[];
    var left = price;
    for (var i = count - 1; i >= 0 && left > 0; i--) {
      if (coins[i] <= left) {
        out.add(coins[i]);
        left -= coins[i];
      }
    }
    return left == 0 ? out : null;
  }

  /// Every other coin from [top] downward, the tidy run that ends at
  /// the top: 55, 21, 8, 3, 1 for a top of 55.
  static List<int> alternate(int top) => [for (var i = placeOf(top); i >= 0; i -= 2) coins[i]];
}

/// Coins told in words: '89 and 1', '55, 34 and 8'.
String tellCoins(Iterable<int> coins) {
  final list = coins.toList();
  if (list.isEmpty) return 'no coins';
  if (list.length == 1) return '${list.first}';
  return '${list.sublist(0, list.length - 1).join(', ')} and ${list.last}';
}
