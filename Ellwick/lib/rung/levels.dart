import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The One Over',
      kind: 'over',
      ways: 3,
      aim: (2, 3),
      note: 'Three squared is nine, twice two squared is eight: one over. So '
          'are 17 and 12, 289 to 288, and 99 and 70, 9,801 to 9,800, and no '
          'other pair to 120: 3 of the 14,400. They are the second, fourth '
          'and sixth rungs of the ladder.',
    ),
    Level(
      name: 'The One Under',
      kind: 'under',
      ways: 3,
      aim: (5, 7),
      note: 'One and one miss by one under, 1 to 2; so do 7 and 5, 49 to 50, '
          'and 41 and 29, 1,681 to 1,682, and no other pair to 120: 3 of the '
          '14,400, the first, third and fifth rungs. The ladder\'s miss turns '
          'over at every rung, and the algebra says why: twice the side plus '
          'the diagonal, squared, less twice the square of side plus '
          'diagonal, is twice the side squared less the diagonal squared.',
    ),
    Level(
      name: 'The Thousandth',
      kind: 'thousandth',
      ways: 7,
      aim: (29, 41),
      note: 'Seven pairs to 120 come within a thousandth of the true '
          'diagonal: 41 over 29 first, 0.00042 over, then 58 over 41, 75 over '
          '53, 82 over 58, 99 over 70, 0.00007 over, 106 over 75 and 116 over '
          '82. The rung 17 over 12 misses by 0.00245, past a thousandth.',
    ),
    Level(
      name: 'The Record',
      kind: 'record',
      ways: 6,
      aim: (12, 17),
      note: 'The pairs that come nearer the true diagonal than every smaller '
          'side does are the six rungs of the ladder and no other: 1 and 1, '
          '3 and 2, 7 and 5, 17 and 12, 41 and 29, 99 and 70. The ladder is '
          'the best whole diagonals there are, rung by rung, all the way to '
          '120, and it never once misses by more than one.',
    ),
    Level(
      name: 'The True Diagonal',
      kind: 'true',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. A whole diagonal squared is never '
          'twice a whole side squared: the diagonal squared would be even, so '
          'the diagonal even and its square a multiple of four, so the side '
          'squared even and the side even, and halving both gives a smaller '
          'pair of the same kind, which cannot go on for ever. None of the '
          '14,400 lands it, and the top rung, 99 and 70, misses by one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
