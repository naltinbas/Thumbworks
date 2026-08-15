import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Perfect',
      kind: 'perfect',
      ways: 3,
      aim: 28,
      note: 'Six is 1, 2 and 3; twenty-eight is 1, 2, 4, 7 and 14; and 496 '
          'is 1, 2, 4, 8, 16, 31, 62, 124 and 248: three numbers of the 500 '
          'add up to themselves, and no other. Every one is a power of two '
          'times one less than the next power, 2 by 3, 4 by 7, 16 by 31, '
          'with that odd number prime, just as Euclid built them.',
    ),
    Level(
      name: 'The Friends',
      kind: 'friends',
      ways: 2,
      aim: 220,
      note: 'The divisors of 220, 1, 2, 4, 5, 10, 11, 20, 22, 44, 55 and 110, '
          'add up to 284, and the divisors of 284, 1, 2, 4, 71 and 142, add '
          'up to 220: each pays the other. They are the only such pair '
          'with a number under 500, 2 settings of the 500, and the oldest '
          'known, Pythagoras\'s.',
    ),
    Level(
      name: 'The Abundant',
      kind: 'abundantSmall',
      ways: 2,
      aim: 12,
      note: 'Twelve is the first number whose divisors add up to more than '
          'it, 1, 2, 3, 4 and 6 making 16, and eighteen the second, 1, 2, '
          '3, 6 and 9 making 21: 2 settings under twenty. Of the 500, 121 '
          'are abundant, and every one of them is even: the first odd one '
          'is 945, past the dial.',
    ),
    Level(
      name: 'The Twice Over',
      kind: 'twice',
      ways: 1,
      aim: 120,
      note: 'The divisors of 120, fifteen of them from 1 to 60, add up to '
          '240, twice the number: the one setting of the 500 that does it. '
          'The next, 672, is past the dial.',
    ),
    Level(
      name: 'The Power of Two',
      kind: 'powerOfTwo',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. The divisors of a power of two '
          'are the powers below it, and 1 + 2 + 4 + ... up to half of it '
          'add up to one less than it, every time: 256 gets 255. Nine '
          'numbers of the 500 come one short, and they are exactly the '
          'powers of two, 1 to 256; none of the 500 lands the ask.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
