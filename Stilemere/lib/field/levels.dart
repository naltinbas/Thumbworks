import 'level.dart';
import 'rules.dart';

/// The five fields that ship.
///
/// Every number here is checked before the bake: every route walked,
/// Pascal's rule and the binomial held to the walk, and
/// tool/check_walks.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Stile',
      field: Field(3, 3, stiles: [(1, 2)]),
      ways: 9,
      walks: 20,
      note: 'Six steps to the mill, three of them right, and 20 ways to '
          'choose which. The stile at (1, 2) is three steps from the gate, '
          'one of them right, 3 ways, and three from the mill, two right, '
          '3 ways: 3 times 3 is 9 routes over it.',
    ),
    Level(
      name: 'The Pond',
      field: Field(3, 3, ponds: [(2, 1)]),
      ways: 11,
      walks: 20,
      note: 'Nine of the 20 routes stand on (2, 1), 3 ways there and 3 on, '
          'and 11 go round it. Pascal\'s rule counts them at every junction '
          'with the pond struck out: the numbers on the field are that '
          'count, each the sum of the one to its left and the one below.',
    ),
    Level(
      name: 'The Two Stiles',
      field: Field(4, 4, stiles: [(1, 1), (3, 2)]),
      ways: 18,
      walks: 70,
      note: 'Eight steps and 70 routes; 2 ways to the first stile, 3 from it '
          'to the second, 3 from there to the mill, and 2 times 3 times 3 is '
          '18.',
    ),
    Level(
      name: 'The Long Field',
      field: Field(5, 4, stiles: [(2, 3)], ponds: [(1, 1)]),
      ways: 16,
      walks: 126,
      note: 'Nine steps and 126 routes. Ten reach the stile at (2, 3), but 6 '
          'of them stand on the pond at (1, 1), so 4 reach it dry; 4 go on to '
          'the mill; 4 times 4 is 16.',
    ),
    Level(
      name: 'The Crossed Stiles',
      field: Field(4, 4, stiles: [(1, 3), (3, 1)]),
      ways: 0,
      walks: 70,
      note: 'Every step goes right or up, so a walk never comes back down or '
          'back left. From the stile at (1, 3) the one at (3, 1) lies below, '
          'and from (3, 1) the other lies to the left: whichever you pass '
          'first, the other is behind you. None of the 70 routes passes '
          'both.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
