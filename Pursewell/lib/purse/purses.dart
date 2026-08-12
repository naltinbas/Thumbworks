import 'purse.dart';

/// The five purses that ship.
///
/// Every number here is checked before the bake: the sweep, the
/// greedy walk and the census, and tool/check_purses.dart
/// refuses the lot if anything disagrees.
class Purses {
  static const all = [
    Purse(
      name: 'The Eleven',
      price: 11,
      ways: 1,
      note: 'Eleven is eight and three, and nothing else lawful: '
          'the sweep tried every handful.',
    ),
    Purse(
      name: 'The Nineteen',
      price: 19,
      ways: 1,
      note: 'Three coins this time, 13 and 5 and 1, each two '
          'steps clear of the next: the greedy finds them '
          'largest first.',
    ),
    Purse(
      name: 'The Thirty',
      price: 30,
      ways: 1,
      note: 'Thirty is 21 and 8 and 1. Reaching for 13 first '
          'strands you: 30 less 13 is 17, and 17 wants 13 '
          'again, its neighbour or itself.',
    ),
    Purse(
      name: 'The Forty-Seven',
      price: 47,
      ways: 1,
      note: 'Two coins pay it: 34 and 13, neighbours in the '
          'purse but not in the coinage, with 21 standing '
          'between them unspent.',
    ),
    Purse(
      name: 'The Second Way',
      price: 12,
      secondWay: true,
      ways: 0,
      note: 'Twelve pays as 8 and 3 and 1, and Zeckendorf\'s '
          'theorem says that is the end of it: the sweep tried '
          'every lawful handful for every purse from one to a '
          'hundred and found exactly one payment each, the '
          'greedy\'s own, every time.',
    ),
  ];

  static int get count => all.length;

  static Purse at(int number) => all[number];
}
