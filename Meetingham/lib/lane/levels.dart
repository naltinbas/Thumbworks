import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Medians',
      kind: 'middles',
      ways: 1,
      aim: (6, 6, 6),
      note: 'Every gate at its middle: the three lanes are the medians, and '
          'they meet at (4, 4), a third of the way up and across, the '
          'centre of the field, one setting of the 1,331. Ceva\'s product '
          'is 1 times 1 times 1.',
    ),
    Level(
      name: 'The One Middle',
      kind: 'oneMiddle',
      ways: 30,
      aim: (2, 10, 6),
      note: 'Thirty settings of the 1,331 meet with one gate at a middle and '
          'the other two off it, and those thirty are all the meetings there '
          'are besides the medians: with twelve paces to a side, every '
          'meeting has a middle gate, since the ratios a gate can cut, 1:11 '
          'to 11:1, pair off to one only through 1:1.',
    ),
    Level(
      name: 'The Quarter',
      kind: 'quarter',
      ways: 2,
      aim: (3, 6, 9),
      note: 'The gate on BC a quarter of the way from B cuts it 1:3, so the '
          'other two must multiply to 3:1: E at the middle and F at 3:1 from '
          'A, or E at 3:1 from C and F at the middle, two settings of the '
          '1,331.',
    ),
    Level(
      name: 'The Two Set',
      kind: 'twoSet',
      ways: 1,
      aim: (4, 8, 6),
      note: 'D a third from B cuts BC 1:2 and E two thirds from C cuts CA 2:1, '
          'so F must cut AB 1:1, the middle: one setting, and the lanes meet '
          'at (24/5, 12/5), which the crossing finds in whole-number '
          'arithmetic.',
    ),
    Level(
      name: 'The Thirds',
      kind: 'thirds',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. Every gate a third of the way '
          'from its corner, the same way round, cuts its side 1:2, and 1:2 '
          'times 1:2 times 1:2 is 1:8, not 1:1, so the lanes never meet: the '
          'crossing of the first two lanes misses the third on the one '
          'setting that has it, and two thirds round the other way gives '
          '8:1 and misses too.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
