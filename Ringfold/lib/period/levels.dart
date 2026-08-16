import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Eight',
      kind: 'period',
      period: 8,
      ways: 1,
      note: 'On the three-hour clock the Fibonacci numbers run 0, 1, 1, 2, '
          '0, 2, 2, 1 and then 0, 1 again: eight steps, and only the '
          'three-hour clock has eight on the dial. The two-hour clock has '
          'three, 0, 1, 1, and the four-hour six, 0, 1, 1, 2, 3, 1.',
    ),
    Level(
      name: 'The Twenty',
      kind: 'period',
      period: 20,
      ways: 1,
      note: 'On the five-hour clock the period is twenty, 0, 1, 1, 2, 3, 0, 3, '
          '3, 1, 4, 0, 4, 4, 3, 2, 0, 2, 2, 4, 1, a nought every five steps, '
          'and five alone has twenty on the dial. For a prime clock the '
          'period divides p - 1 when p ends in 1 or 9 and 2(p + 1) when it '
          'ends in 3 or 7: 11 has 10, 29 has 14, 7 has 16 and 13 has 28.',
    ),
    Level(
      name: 'The Sixty',
      kind: 'period',
      period: 60,
      ways: 3,
      note: 'The last digit of the Fibonacci numbers comes round every sixty, '
          'the ten-hour clock\'s period, and the twenty-hour and forty-hour '
          'clocks have sixty too: three clocks of the 39. Doubling the hours '
          'from ten leaves the period at sixty, while the twenty-five-hour '
          'clock has a hundred and the fifty-hour would have three hundred.',
    ),
    Level(
      name: 'The Own Length',
      kind: 'own',
      ways: 1,
      note: 'The twenty-four-hour clock is the one clock on the dial whose '
          'period is its own length, twenty-four, and the next such clock '
          'is a hundred and twenty. Twenty-four is 8 times 3; the eight-hour '
          'clock has period 12 and the three-hour 8, whose least common '
          'multiple is 24, which is how a clock\'s period comes from its '
          'prime powers.',
    ),
    Level(
      name: 'The Odd Period',
      kind: 'odd',
      ways: 0,
      note: 'Hopeless, and the tile says so. Cassini\'s identity, F(n - 1) '
          'times F(n + 1) less F(n) squared is plus or minus one with the '
          'sign turning each step, holds on every clock; if the period were '
          'odd, the step at the period would give 1 and -1 at once, so 2 '
          'would be nothing on the clock, and only the two-hour clock has '
          'that. On the dial every clock from three to forty has an even '
          'period, six on the four-hour clock the shortest, and two alone '
          'has three.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
