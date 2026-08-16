import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Ninety',
      price: 90,
      kind: 'tidy',
      ways: 1,
      all: 5,
      note: 'Five pickings of the purse pay 90, and one of them is tidy, 89 '
          'and 1: the greedy purse takes the 89 first, the dearest coin not '
          'over the price, and every price from nought to 143 is paid tidily '
          'in exactly one way, the greedy way, 144 tidy pickings for 144 '
          'prices.',
    ),
    Level(
      name: 'The Tidy Top',
      price: 143,
      kind: 'tidy',
      ways: 1,
      all: 1,
      note: '143 is the dearest price the tidy purse pays, 89, 34, 13, 5 and '
          '2, every other coin from the top, and no other picking of the '
          'purse pays it at all: every other coin from a coin down adds to '
          'one short of the coin above it, 1, 2, 4, 7, 12, 20, 33, 54, 88 '
          'and 143, and those are the only prices below 144 paid one way.',
    ),
    Level(
      name: 'The Untidy Hundred',
      price: 100,
      kind: 'untidy',
      ways: 8,
      all: 9,
      note: 'Nine pickings pay 100, and eight of them are untidy, 55, 34, 8 '
          'and 3 the shortest of them; the tidy one is 89, 8 and 3, three '
          'coins, and no picking pays 100 with fewer, since the greedy '
          'purse uses the fewest coins for every price it pays.',
    ),
    Level(
      name: 'The Unminted',
      price: 144,
      kind: 'any',
      ways: 5,
      all: 5,
      note: '144 is 89 and 55 added, the coin the mint never struck, and the '
          'purse pays it five ways, 89 and 55 the shortest, every one of '
          'them untidy: the tidy purse tops out at 143, one short.',
    ),
    Level(
      name: 'The Held-Back Coin',
      price: 90,
      kind: 'tidy',
      barred: 89,
      ways: 0,
      all: 5,
      note: 'Hopeless, and the tile says so. With the 89 kept back the tidy '
          'purse pays 88 at most, 55, 21, 8, 3 and 1, one short of the 89, '
          'and never 90: every other coin from a coin down adds to one short '
          'of the coin above it, and the sweep finds 89 tidy pickings '
          'without the 89, paying nought to 88 once each. Zeckendorf proved '
          'in 1972, and Lekkerkerker before him in 1952, that every number '
          'is a sum of Fibonacci numbers no two neighbours in exactly one '
          'way, and this is why: without the dearest coin that fits, the '
          'rest fall short.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
