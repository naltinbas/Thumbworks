import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Hundredth',
      kind: 'within',
      share: (1, 2),
      bound: (1, 100),
      ways: 34,
      note: 'Halving what is left, the steps run 1/2, 1/4, 1/8 and on, and '
          'after seven they add to 127/128, within a hundredth of the wall '
          'with 1/128 to go; six leave 1/64, more than a hundredth. '
          'Thirty-four settings of the 200 land it, seven halvings to forty. '
          'To get within a thousandth takes ten halvings, and within a '
          'millionth twenty, leaving 1/1,048,576.',
    ),
    Level(
      name: 'The Quarter Left',
      kind: 'exactly',
      bound: (1, 4),
      ways: 2,
      note: 'A quarter is left after two halvings, 1/2 and 1/4 covering 3/4, '
          'and after one step of three quarters, which leaves a quarter at '
          'once; no other setting on the dial stops there. A third and two '
          'thirds leave powers of 2/3 and 1/3, and nine tenths powers of '
          '1/10, none of them a quarter.',
    ),
    Level(
      name: 'The Thousandth by Tenths',
      kind: 'within',
      share: (9, 10),
      bound: (1, 1000),
      ways: 38,
      note: 'Nine tenths of what is left each step leaves a tenth, then a '
          'hundredth, then a thousandth: three steps land within a '
          'thousandth, 999/1,000 covered, and thirty-eight settings of the '
          '200 do, three steps to forty. Halving takes ten steps to the same '
          'mark, a third eighteen, two thirds seven and three quarters five.',
    ),
    Level(
      name: 'The Sixty-Fourth',
      kind: 'exactly',
      bound: (1, 64),
      ways: 2,
      note: 'One part in sixty-four is left after six halvings, the steps 1/2 '
          'to 1/64 covering 63/64, and after three steps of three quarters, '
          'each leaving a quarter of a quarter: two settings of the 200. '
          'Sixty-four is 2 to the sixth and 4 to the third, and no power of '
          '2/3, 1/3 or 1/10 is a sixty-fourth.',
    ),
    Level(
      name: 'The Wall',
      kind: 'wall',
      ways: 0,
      note: 'Hopeless, and the tile says so. Every step covers a share of what '
          'is left and leaves the rest, and the rest of something is '
          'something: after twenty halvings 1/1,048,576 is left, after forty '
          '1/1,099,511,627,776, and after forty steps of nine tenths one part '
          'in 10 to the fortieth, but never nothing. The steps add up to as '
          'near the whole as you please and never to it; the sweep of all 200 '
          'settings finds none at the wall. Zeno set it as a paradox in the '
          'fifth century BC: the endless steps add up to exactly the whole, '
          'and yet no step is the last.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
