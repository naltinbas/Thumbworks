import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two Inside',
      kind: 'two',
      ways: 5572,
      note: 'Of the 6,460 lines through two pegs of the field, 6,140 cross all '
          'three side-lines, the rest running parallel to a side or through a '
          'corner, and 5,572 of those cut two sides inside the triangle and '
          '568 none, never one and never three: a line that goes into a '
          'triangle comes out again, once. The first, through (1, 0) and '
          '(2, 1), cuts AB at (1, 0) and BC at (13/2, 11/2) inside, and CA at '
          '(0, -1) below A, the ratios 1/11, 11/13 and -13 multiplying to -1.',
    ),
    Level(
      name: 'The Middle Cut',
      kind: 'middle',
      ways: 90,
      note: 'Ninety lines cut AB at its middle, (6, 0), AF:FB being 1, and every '
          'one of them cuts one more side inside, so BD:DC and CE:EA are then '
          'each other\'s negatives turned over: through (6, 0) and (0, 1) '
          'they are -1/11 and 11, and through (6, 0) and (0, 4) they are -1/2 '
          'and 2. Sixteen of the ninety cut all three side-lines at pegs.',
    ),
    Level(
      name: 'The Whole Cuts',
      kind: 'whole',
      ways: 152,
      note: 'A hundred and fifty-two lines cut the three side-lines at pegs, 126 '
          'of them with two sides cut inside and 26 wholly outside the '
          'triangle; the first, through (1, 0) and (0, 2), cuts AB at (1, 0), '
          'CA at (0, 2) and BC far out at (-10, 22), the ratios 1/11, -11/5 '
          'and 5. Through (2, 4) and (6, 6) the cuts are (-6, 0), (6, 6) and '
          '(0, 3), the ratios -1/3, 1 and 3, BC cut at its middle.',
    ),
    Level(
      name: 'The Twice',
      kind: 'twice',
      ways: 74,
      note: 'BC is cut twice as far from B as from C at (4, 8), and seventy-four '
          'lines through that peg cross the other two side-lines, every line '
          'through it but the two that run parallel to AB and CA, the line to '
          'A and BC itself; on every one AF:FB times CE:EA is -1/2, since the '
          'three ratios multiply to -1: through (1, 0) they are 1/11 and '
          '-11/2, and through (0, 4) they are -1/4 and 2.',
    ),
    Level(
      name: 'The Three Inside',
      kind: 'three',
      ways: 0,
      note: 'Hopeless, and the tile says so. A straight line that goes into a '
          'triangle at one side comes out at another and cannot come back for '
          'the third, so it cuts two sides inside or none: the sweep of all '
          '6,140 lines through two pegs that cross the three side-lines finds '
          '5,572 cutting two inside and 568 none, and not one cutting one or '
          'three. Menelaus\'s theorem holds on every one, the three ratios '
          'multiplying to -1, an odd count of them negative.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
