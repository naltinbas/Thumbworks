import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Middle',
      kind: 'middle',
      ways: 15,
      note: 'Two chords cross at the middle only when both are diameters, and '
          'the wheel has six, one for each pair of pegs across from each '
          'other, so fifteen crossings of the 495 land it, every piece 5 and '
          'every product 25, the radius squared. Every four pegs of the twelve '
          'give exactly one crossing pair, the two ways across the four, and '
          '495 is the number of fours.',
    ),
    Level(
      name: 'The Nine',
      kind: 'power',
      power: 9,
      ways: 4,
      note: 'The pieces multiply to 9 when the crossing lies 4 from the middle, '
          'since 25 less 16 is 9, and only four crossings do, at (0, 4), (0, '
          '-4), (4, 0) and (-4, 0): a diameter cut 1 and 9 across a chord of '
          'two 3s. The first, (0, 5) to (0, -5) across (3, 4) to (-3, 4), '
          'meets at (0, 4).',
    ),
    Level(
      name: 'The Twenty',
      kind: 'power',
      power: 20,
      ways: 48,
      note: 'Twenty is the commonest product on the wheel, 48 crossings of the '
          '495, all of them at the eight points (2, 1), (1, 2) and their '
          'turnings, root five from the middle, six crossings each. The '
          'first, (0, 5) to (4, -3) across (3, 4) to (0, -5), meets at (2, 1) '
          'with pieces root 20 and root 20 on the one and root 10 and root 40 '
          'on the other, 20 both.',
    ),
    Level(
      name: 'The Halved',
      kind: 'halved',
      ways: 64,
      note: 'Sixty-four crossings of the 495 cut one chord in half away from '
          'the middle, and in every one the line from the middle to the '
          'crossing stands square to the halved chord, which is never a '
          'diameter; the first, (0, 5) to (4, 3) halved at (2, 4) by (3, 4) to '
          '(-3, 4), has pieces root 5 and root 5 against 1 and 5, both 5. No '
          'crossing halves both chords but the middle, where two diameters '
          'halve each other.',
    ),
    Level(
      name: 'The Odd Cross',
      kind: 'differ',
      ways: 0,
      note: 'Hopeless, and the tile says so. Join A to C and B to D, and the '
          'triangles PAC and PDB share their angles, the ones at A and D '
          'standing on the same arc, so PA over PD is PC over PB and PA times '
          'PB is PC times PD; on this wheel both are 25 less the crossing\'s '
          'distance from the middle squared. The sweep of all 495 crossings '
          'finds the two products equal every time.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
