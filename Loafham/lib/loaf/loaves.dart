import 'loaf.dart';

/// The five shares that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every set of cuts on the board, the greedy cut held to it, and
/// tool/check_loaves.dart refuses the lot if anything disagrees.
class Loaves {
  static const all = [
    Loaf(
      name: 'The Two of Three',
      num: 2,
      den: 3,
      cuts: 2,
      ways: 1,
      note: 'A half and a sixth, and no other pair on the board; the '
          'greedy cut finds the same two.',
    ),
    Loaf(
      name: 'The Four of Five',
      num: 4,
      den: 5,
      cuts: 3,
      ways: 2,
      note: 'Two ways in three cuts: a half, a quarter and a twentieth, '
          'which is the greedy cut, or a half, a fifth and a tenth.',
    ),
    Loaf(
      name: 'The Nine of Ten',
      num: 9,
      den: 10,
      cuts: 3,
      ways: 1,
      note: 'One way in three cuts, a half, a third and a fifteenth, '
          'and it is the greedy cut; no two cuts on the board make it.',
    ),
    Loaf(
      name: 'The Five of Seven',
      num: 5,
      den: 7,
      cuts: 3,
      ways: 2,
      note: 'The greedy cut asks for a half, a fifth and a seventieth, '
          'and a seventieth is off the board; the sweep finds two ways '
          'within it, a half, a sixth and a twenty-first, or a half, a '
          'seventh and a fourteenth.',
    ),
    Loaf(
      name: 'The Two Cuts',
      num: 4,
      den: 5,
      cuts: 2,
      ways: 0,
      note: 'With a half, three tenths are left, and no single cut is '
          'three tenths; without a half, the two biggest cuts are a '
          'third and a quarter, seven twelfths, short of four fifths.',
    ),
  ];

  static int get count => all.length;

  static Loaf at(int number) => all[number];
}
