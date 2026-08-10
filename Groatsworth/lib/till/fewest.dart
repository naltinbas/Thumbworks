import 'till.dart';

/// The fewest coins an amount takes from a till, and one way of making it.
class Counting {
  const Counting({required this.fewest, required this.coins});

  final int fewest;

  /// How many of each kind, smallest first, matching the till's order.
  final List<int> coins;
}

/// Works out the fewest coins for every amount a till will be asked for.
///
/// One table, filled from a penny upwards: the fewest coins for an amount is
/// one more than the fewest for whatever taking one coin leaves, tried over
/// every coin in the till. Nothing about it is clever and nothing about it can
/// be wrong, which is the point: it is the measure the quick way is held
/// against.
class Fewests {
  Fewests(this.till, {int upTo = 1200}) {
    _fewest = List.filled(upTo + 1, 1 << 20);
    _took = List.filled(upTo + 1, -1);
    _fewest[0] = 0;
    for (var amount = 1; amount <= upTo; amount++) {
      for (var kind = 0; kind < till.kinds; kind++) {
        final coin = till.coins[kind].pence;
        if (coin > amount) break;
        if (_fewest[amount - coin] + 1 < _fewest[amount]) {
          _fewest[amount] = _fewest[amount - coin] + 1;
          _took[amount] = kind;
        }
      }
    }
  }

  final Till till;

  late final List<int> _fewest;
  late final List<int> _took;

  int fewestFor(int amount) => _fewest[amount];

  /// One way of making an amount in the fewest coins.
  Counting countingFor(int amount) {
    final coins = List.filled(till.kinds, 0);
    var left = amount;
    while (left > 0) {
      final kind = _took[left];
      coins[kind]++;
      left -= till.coins[kind].pence;
    }
    return Counting(fewest: _fewest[amount], coins: coins);
  }

  /// What the quick way gives: the biggest coin that fits, over and over. It
  /// is what everybody behind a counter does, and on the old till it is not
  /// always the fewest.
  Counting byBiggest(int amount) {
    final coins = List.filled(till.kinds, 0);
    var left = amount;
    var used = 0;
    while (left > 0) {
      var kind = till.kinds - 1;
      while (till.coins[kind].pence > left) {
        kind--;
      }
      coins[kind]++;
      used++;
      left -= till.coins[kind].pence;
    }
    return Counting(fewest: used, coins: coins);
  }

  /// The same answer as the table, found by trying every mix of coins. Slow
  /// and stupid on purpose: it is what holds the table to account in a test.
  int byTrying(int amount) {
    var best = 1 << 20;

    void grow(int kind, int left, int used) {
      if (used >= best) return;
      if (left == 0) {
        best = used;
        return;
      }
      if (kind < 0) return;
      final pence = till.coins[kind].pence;
      final most = left ~/ pence;
      for (var take = most; take >= 0; take--) {
        grow(kind - 1, left - take * pence, used + take);
      }
    }

    grow(till.kinds - 1, amount, 0);
    return best;
  }

  /// Every amount up to a bound where the quick way uses more coins than the
  /// fewest.
  List<int> whereBiggestFails(int upTo) => [
        for (var amount = 1; amount <= upTo; amount++)
          if (byBiggest(amount).fewest > _fewest[amount]) amount,
      ];

  /// The plain floor under an amount: no pile of k coins can come to more
  /// than k times the largest coin, so fewer than the ceiling of the amount
  /// over the largest cannot reach it. A player can check it with one
  /// multiplication.
  int floorFor(int amount) =>
      (amount + till.largest.pence - 1) ~/ till.largest.pence;
}
