import 'level.dart';

/// The five yards that ship.
///
/// Every number here is checked before the bake: every yard from four
/// to eleven walked with the drain on every flag, the colouring held to
/// the walk on all of them, and tool/check_tilings.dart refuses the lot
/// if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Four Yard',
      side: 4,
      drainRow: 0,
      drainCol: 0,
      drainWords: 'in the corner',
      ways: 4,
      note: 'Sixteen flags less the drain is fifteen, five bricks; the four '
          'yard paves round a corner drain four ways, and round no other flag: '
          'the corners alone wear the odd colour of both slants.',
    ),
    Level(
      name: 'The Five Yard',
      side: 5,
      drainRow: 2,
      drainCol: 2,
      drainWords: 'in the middle',
      ways: 2,
      note: 'Twenty-four flags, eight bricks, and the middle is the only drain '
          'the five yard paves round, two ways: rings of bricks round it, one '
          'way and the other.',
    ),
    Level(
      name: 'The Seven Yard',
      side: 7,
      drainRow: 3,
      drainCol: 3,
      drainWords: 'in the middle',
      ways: 258,
      note: 'Forty-eight flags, sixteen bricks; the seven yard paves round nine '
          'drains, the flags whose row and column are both nought, three or '
          'six from the corner, and round the middle 258 ways.',
    ),
    Level(
      name: 'The Eight Yard',
      side: 8,
      drainRow: 2,
      drainCol: 2,
      drainWords: 'two flags in from the corner',
      ways: 356,
      note: 'Sixty-three flags, twenty-one bricks; the eight yard paves round '
          'four drains only, the flags two in from each corner, 356 ways each, '
          'which is Golomb\'s old answer to the board with a square missing.',
    ),
    Level(
      name: 'The Corner Drain',
      side: 8,
      drainRow: 0,
      drainCol: 0,
      drainWords: 'in the corner',
      ways: 0,
      note: 'Colour the flags along the slant in three colours: twenty-two wear '
          'one colour and twenty-one each of the others, and every brick, across '
          'or down, covers one flag of each. The corner wears a colour with '
          'twenty-one, so with the drain there twenty-two of one colour are left '
          'against twenty of another, and no bricks ever balance them.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
