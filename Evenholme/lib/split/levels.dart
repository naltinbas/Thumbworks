import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Twenty',
      number: 20,
      ways: 2,
      note: 'Twenty splits as 3 + 17 and as 7 + 13, two of the nine picks '
          'from 2 to 10. Every even number from 4 to 2,000 splits, and only '
          '4, 6, 8 and 12 split one way alone: 2 + 2, 3 + 3, 3 + 5 and 5 + 7.',
    ),
    Level(
      name: 'The Twins',
      number: 60,
      kind: 'twins',
      ways: 1,
      note: 'Sixty splits six ways, 7 + 53, 13 + 47, 17 + 43, 19 + 41, 23 + '
          '37 and 29 + 31, and the last pair are twins, two apart: one pick '
          'of the 29.',
    ),
    Level(
      name: 'The Wide',
      number: 98,
      kind: 'over',
      ways: 2,
      note: 'Ninety-eight splits three ways, 19 + 79, 31 + 67 and 37 + 61, '
          'and two of them keep both primes over thirty: two picks of the '
          '48. Above 100 no even number splits fewer than three ways, and '
          '128 is the first with just three.',
    ),
    Level(
      name: 'The Hundred',
      number: 100,
      ways: 6,
      note: 'A hundred splits six ways: 3 + 97, 11 + 89, 17 + 83, 29 + 71, '
          '41 + 59 and 47 + 53, six picks of the 49. Of the evens to 2,000 '
          'the most ways is 91, at 1,890, and there are 303 primes to 2,000 '
          'to split with.',
    ),
    Level(
      name: 'The Odd',
      number: 51,
      ways: 0,
      note: 'Hopeless, and the tile says so. Two odd primes add up to an even '
          'number, so an odd number splits only with a 2 in it, and 51 less 2 '
          'is 49, seven sevens: none of the 24 picks lands it. Its neighbours '
          'both split, 50 as 3 + 47, 7 + 43, 13 + 37 and 19 + 31, and 52 as '
          '5 + 47, 11 + 41 and 23 + 29.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
