import 'share.dart';

/// The five shares that ship.
///
/// Every number here is checked before the bake: the sweep at
/// every share, Prouhet's pattern and his polynomial held to it,
/// and tool/check_shares.dart refuses the lot if anything
/// disagrees.
class Shares {
  static const all = [
    Share(
      name: 'The Four',
      count: 4,
      degrees: 1,
      ways: 1,
      note: 'One share of four agrees in sums, 1 and 4 against 2 '
          'and 3, and it is Prouhet\'s pattern at its first '
          'doubling.',
    ),
    Share(
      name: 'The Eight',
      count: 8,
      degrees: 2,
      ways: 1,
      note: 'Four shares of eight agree in sums; ask the squares '
          'too and one is left, 1, 4, 6, 7 against 2, 3, 5, 8, '
          'which is Prouhet\'s pattern at its third doubling.',
    ),
    Share(
      name: 'The Dozen',
      count: 12,
      degrees: 2,
      ways: 1,
      note: 'Twenty-nine shares of the dozen agree in sums and '
          'one in squares too, 1, 3, 7, 8, 9, 11 against the '
          'rest, with no doubling behind it: twelve is not a '
          'power of two.',
    ),
    Share(
      name: 'The Sixteen',
      count: 16,
      degrees: 3,
      ways: 1,
      note: 'Of the 6,435 shares of sixteen, 263 agree in sums, '
          '7 in squares too, and one in cubes as well: Prouhet\'s '
          'pattern at its fourth doubling, token 1 with every '
          'token whose number less one has an even count of ones '
          'written in twos.',
    ),
    Share(
      name: 'The Four Squared',
      count: 4,
      degrees: 2,
      ways: 0,
      note: 'Four tokens pair off three ways only: 1 and 2 '
          'against 3 and 4 sum to 3 and 7, 1 and 3 against 2 and '
          '4 to 4 and 6, and 1 and 4 against 2 and 3 to 5 and 5, '
          'whose squares come to 17 and 13.',
    ),
  ];

  static int get count => all.length;

  static Share at(int number) => all[number];
}
