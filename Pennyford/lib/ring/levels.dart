import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Four',
      count: 4,
      ways: 6,
      aim: (1, 2),
      note: 'Coins bigger than the middle: rings of two round a one, three '
          'or four round a two, five or six round a three, six round a '
          'four, 6 settings of 36. Each takes between a fifth and a quarter '
          'of the turn, so four fit and a fifth does not; two round a one '
          'leave 25.5 degrees to spare.',
    ),
    Level(
      name: 'The Six',
      count: 6,
      ways: 8,
      aim: (1, 1),
      note: 'Equal coins take a sixth of the turn each, sixty degrees to the '
          'thousandth and beyond, so six fit with nothing to spare and a '
          'seventh never: 6 settings of 36 are equal coins, and two more, '
          'four round a five and five round a six, fit six with room left, '
          '43.3 and 35.6 degrees.',
    ),
    Level(
      name: 'The Seven',
      count: 7,
      ways: 3,
      aim: (3, 2),
      note: 'Seven fit when the ring coin is no more than 0.766 of the '
          'middle: twos round a three and fours round a six, 29.9 degrees to '
          'spare, and threes round a four, 4.7 degrees to spare, 3 settings '
          'of 36. Fours round a five, at four fifths, are too big for seven, '
          'and threes round a five fit eight.',
    ),
    Level(
      name: 'The Twelve',
      count: 12,
      ways: 2,
      aim: (3, 1),
      note: 'Twelve fit when the ring coin is a third of the middle: ones '
          'round a three and twos round a six, 12.5 degrees to spare, 2 '
          'settings of 36. Ones round a six go twenty-one times round with '
          '15.0 degrees to spare, the most of any setting.',
    ),
    Level(
      name: 'The Seven Pennies',
      count: 7,
      noSmaller: true,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. A ring coin as big as the '
          'middle takes a sixth of the turn, sixty degrees, since the three '
          'centres make a triangle of equal sides, and a bigger one takes '
          'more; seven sixths are more than a turn. None of the 36 settings '
          'lands it, and equal coins, six exactly, come nearest.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
