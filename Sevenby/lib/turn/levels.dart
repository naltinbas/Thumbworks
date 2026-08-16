import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Six',
      kind: 'period',
      period: 6,
      ways: 18,
      note: 'A seventh is 0.142857 repeating and a thirteenth 0.076923, both '
          'round in six places, eighteen settings of the 308: every k over 7 '
          'and every k over 13. The remainders of a seventh run 1, 3, 2, 6, '
          '4, 5, all six there are, and the block times seven is 999,999; a '
          'thirteenth\'s run 1, 10, 9, 12, 3, 4, six of the twelve, and '
          '076923 times 13 is 999,999 too.',
    ),
    Level(
      name: 'The Full Turn',
      kind: 'full',
      ways: 136,
      note: 'Six primes on the dial take the whole turn, 7, 17, 19, 23, 29 and '
          '47, whose reciprocals repeat every 6, 16, 18, 22, 28 and 46 '
          'places, all p - 1, since 10 comes back to 1 on their clocks only '
          'after every hour but 0 has been passed: 136 settings of the 308. '
          'To a hundred the full-turn primes are 7, 17, 19, 23, 29, 47, 59, '
          '61 and 97, nine of the twenty-three odd primes but five. For each, '
          'k over p reads the same digits as 1 over p from another start, '
          'every k.',
    ),
    Level(
      name: 'The Rotation',
      kind: 'rotation',
      ways: 5,
      note: 'Two sevenths are 0.285714, three 0.428571, four 0.571428, five '
          '0.714285 and six 0.857142: the six digits of a seventh read round '
          'from another start, since the remainders of a seventh visit every '
          'hour, and k over 7 starts where 1 over 7 reaches remainder k. Five '
          'settings besides a seventh itself. On a thirteenth only six of the '
          'twelve read so, 1, 3, 4, 9, 10 and 12 over 13, the remainders a '
          'thirteenth passes; the other six read the digits of 2 over 13, '
          '153846, round.',
    ),
    Level(
      name: 'The Three',
      kind: 'period',
      period: 3,
      ways: 36,
      note: 'A thirty-seventh is 0.027 repeating, three places, and so is every '
          'k over 37, thirty-six settings of the 308: 10 cubed is 1,000, one '
          'more than 27 times 37, so 10 comes back to 1 in three steps on the '
          'thirty-seven-hour clock, and 027 times 37 is 999. The period '
          'always divides p - 1, and 3 divides 36.',
    ),
    Level(
      name: 'The Long Turn',
      kind: 'longer',
      ways: 0,
      note: 'Hopeless, and the tile says so. The remainders in the long division '
          'of k by p are the hours 1 to p - 1, never 0 for a prime that does '
          'not divide k, so within p - 1 steps one comes again and the digits '
          'repeat from there: the period is p - 1 at most, and it always '
          'divides p - 1. On the dial six primes reach the whole turn and '
          'seven fall short, 3, 11, 13, 31, 37, 41 and 43 with periods 1, 2, '
          '6, 15, 3, 5 and 21; the sweep of all 308 fractions finds none '
          'longer.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
