import 'level.dart';

/// The five loads that ship.
///
/// Every number here is checked before the bake: every placing swept,
/// counting in threes held to the sweep, and tool/check_weighings.dart
/// refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Two',
      load: 2,
      ways: 1,
      placings: 81,
      note: 'Two is three less one: the 3 across from the load, the 1 beside '
          'it. Counting in threes with the digits 1, 0 and -1 writes 2 as '
          '1, -1: one three, less one one. One placing of the 81.',
    ),
    Level(
      name: 'The Twenty',
      load: 20,
      ways: 1,
      placings: 81,
      note: 'Twenty is 27 less 9, plus 3, less 1: the 27 and the 3 across, '
          'the 9 and the 1 beside the load, all four weights on the scale. '
          'One placing of the 81, as for every load to forty.',
    ),
    Level(
      name: 'The Thirty-One',
      load: 31,
      ways: 1,
      placings: 81,
      note: 'Thirty-one is 27 and 3 and 1, all across and the 9 off, since '
          '31 in threes with digits 1, 0, -1 is 1, 0, 1, 1. One placing of the '
          '81.',
    ),
    Level(
      name: 'The Forty',
      load: 40,
      ways: 1,
      placings: 81,
      note: 'Forty is every weight across, 1 and 3 and 9 and 27, and forty-one '
          'is past all four; every load from 1 to 40 balances exactly once, '
          'and the 81 placings weigh 81 different amounts, -40 to 40, one '
          'each.',
    ),
    Level(
      name: 'The Ten Without the One',
      load: 10,
      barred: [1],
      ways: 0,
      placings: 27,
      note: 'The 3, the 9 and the 27 are all multiples of three, so any '
          'placing of them weighs a multiple of three against the load, and '
          'ten is not one: 27 placings, and none balances. With the 1 allowed '
          'ten is 9 and 1 across.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
