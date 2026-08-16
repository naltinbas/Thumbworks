import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two of Seven',
      clock: 7,
      kind: 'two',
      ways: 2,
      note: 'The seven-hour clock has three squares, 1, 2 and 4: 1 and 6 '
          'square to 1, 2 and 5 to 4, 3 and 4 to 2, each square reached by a '
          'base and its opposite, a and 7 - a, since their squares differ by '
          'a multiple of seven. Euler\'s test agrees hour by hour: 2 to the '
          'third power is 8, one more than seven, and 3 to the third is 27, '
          'one short.',
    ),
    Level(
      name: 'The Odd Hour',
      clock: 7,
      kind: 'nonSquare',
      ways: 3,
      note: 'Half the hours of any prime clock but 0 are squares and half are '
          'not, three of the six on seven: 3, 5 and 6 are nobody\'s square. '
          'On every prime clock to a hundred, twenty-four of them, the '
          'squares come to exactly half of the hours but 0, since a base and '
          'its opposite square to the same hour and no third base joins '
          'them.',
    ),
    Level(
      name: 'The Minus One',
      kind: 'minusOne',
      ways: 6,
      note: 'One short of the clock is a square only on clocks one more than '
          'a multiple of four: 5, 13 and 17 of the eight on the dial, and '
          'none of 3, 7, 11, 19 and 23; six settings of the 90 land it, 2 and '
          '3 on five, 5 and 8 on thirteen, 4 and 13 on seventeen. Euler\'s '
          'test says why: minus one to the (p - 1) / 2 is 1 only when '
          '(p - 1) / 2 is even. The rule holds on all twenty-four prime '
          'clocks to a hundred.',
    ),
    Level(
      name: 'The Two',
      kind: 'two',
      ways: 6,
      note: 'Two is a square on clocks one more or one less than a multiple '
          'of eight: 7, 17 and 23 of the eight on the dial, six settings of '
          'the 90, 3 and 4 on seven, 6 and 11 on seventeen, 5 and 18 on '
          'twenty-three. On all twenty-four prime clocks to a hundred, two is '
          'a square exactly on those one more or one less than a multiple of '
          'eight.',
    ),
    Level(
      name: 'The Two of Eleven',
      clock: 11,
      kind: 'two',
      ways: 0,
      note: 'Hopeless, and the tile says so. The squares on the eleven-hour '
          'clock are 1, 4, 9, 5 and 3, the squares of 1 to 5, and the bases 6 '
          'to 10 repeat them backwards, so 2 is nobody\'s square, nor 6, 7, 8 '
          'or 10; Euler\'s test agrees, 2 to the fifth being 32, one short of '
          'three elevens. Eleven is one short of a multiple of four and three '
          'past a multiple of eight, on neither side of the rule for two.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
