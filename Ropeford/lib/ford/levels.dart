import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Hundred Ford',
      kind: 'hundred',
      ways: 5,
      note: 'Five dry stones sit past the hundredth on this ford, 101, 103, '
          '107, 109 and 113, and eight hops is the fewest that reaches any '
          'of them. Eight is also what the greedy crossing takes, the one '
          'that always jumps to the farthest stone in reach: 2, 3, 5, 7, 13, '
          '23, 43, 83, 113.',
    ),
    Level(
      name: 'The Twin Stones',
      kind: 'twin',
      ways: 10,
      note: 'Ten stones of the ford have another dry stone two behind them: '
          '5, 7, 13, 19, 31, 43, 61, 73, 103 and 109. Two hops is enough, '
          'since 5 is one of them and the rope from 3 reaches 6.',
    ),
    Level(
      name: 'The Far Bank',
      kind: 'far',
      ways: 13,
      note: 'From stone 61 on, the rope runs past the ford\'s last stone, '
          'which is 13 of the dry stones; seven hops reaches the first of '
          'them. From 113 there is nothing dry left on the ford at all, '
          'though the rope reaches to 226 and the next dry stone, 127, is '
          'well inside it.',
    ),
    Level(
      name: 'The Lonely Stone',
      kind: 'lonely',
      ways: 2,
      note: 'Two stones of the ford have nothing but moss for four stones '
          'either side, 53 and 89, and seven hops reaches 53. The moss round '
          '89 runs longer on the far side than on the near: 90 to 96 is the '
          'first run of seven mossy stones anywhere.',
    ),
    Level(
      name: 'The Long Shallows',
      kind: 'shallows',
      ways: 0,
      note: 'Hopeless, and the board says so in red. The seven stones '
          'between 89 and '
          '97 are all mossy: 90, 92, 94 and 96 are even, 93 is 3 times 31, '
          '95 is 5 times 19, and 91, which looks dry enough, is 7 times 13. '
          'Bertrand promises a dry stone somewhere in the rope\'s reach and '
          'never says where it will be. From stone 89 the rope covers all '
          'seven and reaches on to 178, though the ford stops at 120, and '
          'the dry stones of the ford under it are 97, 101, 103, 107, 109 '
          'and 113.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
