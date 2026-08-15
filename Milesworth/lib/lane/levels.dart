import 'level.dart';

/// The five lanes that ship.
///
/// Every number here is checked before the bake: every run swept, the
/// odd divisors held to the sweep, and tool/check_runs.dart refuses
/// the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Fifteen',
      count: 15,
      ways: 3,
      runs: 105,
      note: 'Fifteen has the odd divisors 3, 5 and 15, and a run for each: '
          '4, 5, 6 centred on 5, three stones; 1 to 5 centred on 3, five '
          'stones; and 7, 8, since fifteen stones centred on 1 fold back '
          'over the start and cancel down to two. Three of the 105 runs.',
    ),
    Level(
      name: 'The Twenty-One',
      count: 21,
      ways: 3,
      runs: 210,
      note: 'Odd divisors 3, 7 and 21: 6, 7, 8; 1 to 6, since seven stones '
          'centred on 3 fold back and leave 1 to 6; and 10, 11. Three of '
          'the 210 runs.',
    ),
    Level(
      name: 'The Thirteen',
      count: 13,
      ways: 1,
      runs: 78,
      note: 'A prime has one odd divisor past 1, itself, so one run: 6 and 7. '
          'Every odd number is the run of two either side of its half, and '
          'a prime is nothing else.',
    ),
    Level(
      name: 'The Forty-Five',
      count: 45,
      ways: 5,
      runs: 990,
      note: 'Odd divisors 3, 5, 9, 15 and 45, five of them, and five runs of '
          'the 990: 14 to 16, 7 to 11, 1 to 9, 5 to 10 and 22, 23. The '
          'fifteen-stone run centred on 3 folds back to 5 through 10.',
    ),
    Level(
      name: 'The Sixteen',
      count: 16,
      ways: 0,
      runs: 120,
      note: 'A run of an odd number of stones is that number times its middle '
          'stone, and a run of an even number is half that number times the '
          'sum of its two middle stones, which is odd; either way an odd '
          'factor past 1 divides the sum. Sixteen has none, being a power of '
          'two, and none of its 120 runs adds to it.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
