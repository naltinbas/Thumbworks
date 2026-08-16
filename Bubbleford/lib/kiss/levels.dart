import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Unit Ring',
      kind: 'unit',
      ways: 27,
      note: 'Bends 2, 2 and 3 give fourths of 15 and -1, a bubble in the gap '
          'fifteen times as bent as a unit bubble and a unit bubble round '
          'the outside, the gasket Descartes and Soddy both drew; 27 of the '
          '8,000 settings ring the three with a unit bubble, 2, 3 and 6 '
          'among them, with 23 in the gap.',
    ),
    Level(
      name: 'The Flat Fourth',
      kind: 'flat',
      ways: 33,
      note: 'The outer bubble flattens to a straight line when the three '
          'bends added are exactly twice the root of the pairwise sum: 33 '
          'settings do it, 1, 1 and 4 the first, two unit bubbles and a '
          'quarter-bubble in the notch, all resting on a line, with a '
          'bubble of bend 12 in the gap; k, k and 4k does it for every k, '
          'and 1, 4 and 9, 1, 9 and 16, and 2, 8 and 18 as well.',
    ),
    Level(
      name: 'The Whole Wrap',
      kind: 'wrap',
      ways: 156,
      note: 'Both fourth bends are whole exactly when the pairwise sum ab + '
          'bc + ca is a square, 207 settings of the 8,000, and 156 of those '
          'wrap the outer bubble round the three, the classic gaskets: 2, '
          '2, 3 with 15 and -1, 2, 3, 6 with 23 and -1, 3, 6, 7 and on.',
    ),
    Level(
      name: 'The Far Gap',
      kind: 'gap',
      ways: 18,
      note: 'When the three bends added outrun twice the root of the '
          'pairwise sum, the outer bubble is no ring at all but a bubble '
          'in the gap on the far side, bend above nought: 966 settings put '
          'it there, and 18 of them with both fourths whole, 1, 1 and 12 '
          'first, fourths 24 and 4, and 1, 4 and 12, fourths 33 and 1.',
    ),
    Level(
      name: 'The Twin Fourths',
      kind: 'twin',
      ways: 0,
      note: 'Hopeless, and the tile says so. The two fourth bends are the '
          'three added, give or take twice the root of ab + bc + ca, and '
          'they are of one bend only when that root is nought, which three '
          'bends above nought never give: three products of positive '
          'numbers add to something above nought. Descartes wrote the '
          'relation to Princess Elisabeth in 1643, and Soddy set it to '
          'verse in 1936; the sweep of all 8,000 settings finds the two '
          'fourths apart on every one, and the relation holding for every '
          'whole fourth found by trial.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
