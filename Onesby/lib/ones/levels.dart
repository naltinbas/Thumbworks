import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Prime That Is Not',
      kind: 'primeNot',
      ways: 3,
      note: 'Of the eleven prime exponents on the dial, 2, 3, 5, 7, 11, 13, '
          '17, 19, 23, 29 and 31, eight give prime rows and three do not: 11 '
          'gives 2,047, which is 23 times 89, 23 gives 8,388,607, 47 times '
          '178,481, and 29 gives 536,870,911, 233 times 2,304,167. A prime '
          'exponent is needed for a prime row, but it is not enough. Trial '
          'division and the Lucas-Lehmer chain agree on all thirty '
          'exponents.',
    ),
    Level(
      name: 'The Twenty-Three',
      kind: 'twentyThree',
      ways: 2,
      note: 'Twenty-three divides the row of eleven ones, 2,047 being 23 times '
          '89, and so the row of twenty-two ones too, since a row of ones '
          'divides any row whose length is a multiple of its own; no other '
          'row on the dial has it. Two to the eleventh is one more than a '
          'multiple of 23, and 11 is prime, so 23 divides no shorter row.',
    ),
    Level(
      name: 'The Perfect Eight Thousand',
      kind: 'perfect',
      ways: 1,
      note: 'Seven ones are 127, prime, and 64 times 127 is 8,128, the fourth '
          'perfect number, its divisors below it adding back to it; Euclid '
          'showed every prime row makes a perfect number this way, and Euler '
          'that every even perfect number is made so. On the dial the perfect '
          'numbers made are 6, 28, 496, 8,128, 33,550,336, 8,589,869,056 and '
          '137,438,691,328, each checked by adding its divisors, and 2 to the '
          'thirtieth times 2,147,483,647 from the last row.',
    ),
    Level(
      name: 'The Longest Row',
      kind: 'longest',
      ways: 1,
      note: 'The row of thirty-one ones, 2,147,483,647, is prime, as Euler '
          'showed in 1772, and it is the longest prime row the dial holds: 29 '
          'gives 233 times 2,304,167 and 30, an even exponent, 3 times '
          '357,913,941. The Lucas-Lehmer chain for 31 runs 29 steps and ends '
          'at 0, and trial division to 46,340 finds no factor.',
    ),
    Level(
      name: 'The Composite Row',
      kind: 'composite',
      ways: 0,
      note: 'Hopeless, and the tile says so. If the exponent is a times b, the '
          'row of a ones divides the row of a times b ones, since 2 to the ab '
          'less 1 is 2 to the a less 1 times a sum of powers, so the row is '
          'composite: four ones, 15, are 3 times 5, and nine ones, 511, are 7 '
          'times 73. On the dial every composite exponent from 4 to 30 gives '
          'a row whose smallest factor is the row of its smallest prime '
          'factor, 3 for the even ones, 7 for 9, 15, 21 and 27, and 31 for '
          '25.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
