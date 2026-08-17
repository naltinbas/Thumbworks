import 'level.dart';

/// The five asks, first to last. Each count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Forty-Two',
      number: 42,
      ways: 1,
      note: 'One setting of the 720 reads 42, as one setting reads every '
          'number the house can reach: 42 is one twenty-four and three sixes, '
          'so the fourth wheel stands at 1 and the third at 3 and the rest at '
          'nothing. Four turns, which is the wheels of 42 added up.',
    ),
    Level(
      name: 'A Hundred',
      number: 100,
      ways: 1,
      note: 'One setting of the 720. A hundred is four twenty-fours and two '
          'twos, so the fourth wheel goes to 4, its top, and the second to 2, '
          'its top, and the third and first stand at nothing. Six turns.',
    ),
    Level(
      name: 'Five Hundred',
      number: 500,
      ways: 1,
      note: 'One setting of the 720. Five hundred is four one-twenties and '
          'three sixes and one two, so the fifth wheel goes to 4, the third '
          'to 3 and the second to 1. Eight turns, and the house is still 219 '
          'short of its top.',
    ),
    Level(
      name: 'Every Wheel Full',
      number: 719,
      ways: 1,
      note: 'One setting of the 720, and the last of them: every wheel at its '
          'top. That is 1 times 1 factorial and 2 times 2 factorial and on to '
          '5 times 5 factorial, and since k times k factorial is (k + 1) '
          'factorial less k factorial the sum folds up to 6 factorial less '
          'one, which is 719. Fifteen turns, the most any reading takes.',
    ),
    Level(
      name: 'Seven Hundred and Twenty',
      number: 720,
      ways: 0,
      note: 'Hopeless, and the card at the end of the ask says so. Turn every '
          'wheel to its top and the house reads 719, one short of 720, so '
          'nothing higher can be read at all. The reason is the telescoping: '
          'each wheel at its top is worth (k + 1) factorial less k factorial, '
          'and adding those from the first wheel to the fifth cancels '
          'everything in the middle and leaves 6 factorial less 1 factorial, '
          'which is 719. All 720 settings of the wheels were read before the '
          'sham was built, and they read the numbers 0 to 719, each of them '
          'once.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
