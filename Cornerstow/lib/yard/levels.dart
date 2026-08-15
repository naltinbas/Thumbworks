import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Three',
      n: 2,
      ways: 12,
      note: 'One and eight cells, nine, the square of one plus two: the three-by-three '
          'is paved twelve ways with the one, the whole two and the two halves, '
          'the halves lying either way up.',
    ),
    Level(
      name: 'The Six',
      n: 3,
      ways: 80,
      note: 'One and eight and twenty-seven, thirty-six, the square of six: eighty '
          'pavings, and Nicomachus\'s own has the one in the corner, the two and '
          'its halves in the band round it, and the three threes in the band '
          'round that.',
    ),
    Level(
      name: 'The Ten',
      n: 4,
      ways: 6892,
      note: 'One, eight, twenty-seven and sixty-four, a hundred, the square of ten: '
          '6,892 pavings; the fourth four is cut in halves too, four by two, one '
          'at each end of its band.',
    ),
    Level(
      name: 'The Fifteen',
      n: 5,
      ways: 51536,
      note: 'The cubes to five come to 225, the square of fifteen, and the yard is '
          'paved 51,536 ways with the seventeen flags; the five fives need no '
          'halves, since fifteen is five threes.',
    ),
    Level(
      name: 'The Three, Whole',
      n: 2,
      whole: true,
      ways: 0,
      note: 'Every two-by-two flag laid in the three-by-three covers the middle '
          'cell, all four places it can lie, so two whole twos overlap wherever '
          'they go, and the one is left with nowhere to make up for it; nor do the '
          'whole flags pave the six, the ten or the fifteen, none of them a single '
          'way, which is why Nicomachus cuts the last even flag in two.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
