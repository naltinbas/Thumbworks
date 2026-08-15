import 'level.dart';

/// The five asks, first to last. Every count is the walk's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Shunts',
      start: [1, 2, 0, 4, 5, 3, 7, 8, 6],
      fewest: 2,
      note: 'The gap has gone up the right-hand side two berths, and two '
          'shunts bring it down again, 3 up and then 6 up: the walk from '
          'home finds this yard two shunts out, one of four at that '
          'distance, its pairs out of order 4.',
    ),
    Level(
      name: 'The Seven',
      start: [1, 5, 2, 4, 8, 0, 7, 6, 3],
      fewest: 7,
      note: 'Seven shunts, and no fewer: the walk from home reaches this '
          'yard on its seventh ring, with 62 yards in all at that distance. '
          'The count of pairs out of order is 10, even, as it must be.',
    ),
    Level(
      name: 'The Twelve',
      start: [2, 4, 3, 7, 6, 8, 5, 1, 0],
      fewest: 12,
      note: 'Twelve shunts, one of 748 yards at that distance. The pairs out '
          'of order come to 12, and every one of the twelve shunts on the '
          'way home leaves the count even, as every shunt does.',
    ),
    Level(
      name: 'The Far Corner',
      start: [8, 6, 7, 2, 5, 4, 3, 0, 1],
      fewest: 31,
      note: 'Thirty-one shunts, and no yard needs more: the walk from home '
          'runs out at 31, and only two of the 181,440 yards it reaches sit '
          'that far, this one and 6 4 7 / 8 5 _ / 3 2 1. The pairs out of '
          'order come to 24.',
    ),
    Level(
      name: 'The Swapped Pair',
      start: [1, 2, 3, 4, 5, 6, 8, 7, 0],
      fewest: null,
      note: 'Hopeless, and the tile says so. Home with the 7 and the 8 '
          'swapped has one pair out of order, and a shunt never changes '
          'whether the count is odd or even: a sideways shunt keeps the '
          'order, and an up-or-down shunt jumps a wagon over the two '
          'between, changing the count by two or by nought. Home has nought, '
          'even; the walk from home never reaches this yard, nor any of the '
          '181,440 with an odd count.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
