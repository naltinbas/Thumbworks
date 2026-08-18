import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Three Tables',
      tables: 3,
      kind: 'any',
      ways: 90,
      fewest: 2,
      note: '90 of the 203 seatings put the six guests at three tables, '
          'which is more than at any other number. The full row runs 1, 31, '
          '90, 65, 15 and 1 for one table up to six, and it adds to the 203. '
          'Three is where the room is widest.',
    ),
    Level(
      name: 'The Three Sizes',
      tables: 3,
      kind: 'different',
      ways: 60,
      fewest: 3,
      note: '60 of the 90 three-table seatings have no two tables holding '
          'the same number. Three different sizes adding to six can only be '
          '1, 2 and 3, so every one of the 60 is that shape, and there are '
          '6 times 5 times 4 ways to pick who sits alone, who pairs and who '
          'makes the three.',
    ),
    Level(
      name: 'The Three Pairs',
      tables: 3,
      kind: 'together',
      ways: 15,
      fewest: 4,
      note: '15 of the 90 leave nobody sitting on their own. Three tables '
          'with two or more at each and only six guests forces two, two and '
          'two, so the ask is really to split the six into three pairs, and '
          'that is 15 ways.',
    ),
    Level(
      name: 'The Even Halves',
      tables: 2,
      kind: 'same',
      ways: 10,
      fewest: 3,
      note: '10 of the 31 two-table seatings hold the same number at each, '
          'which has to be three and three. Picking the three at the near '
          'trestle picks the other three as well, so the 20 ways of choosing '
          'three from six count every seating twice, and 10 are left.',
    ),
    Level(
      name: 'The Four Sizes',
      tables: 4,
      kind: 'different',
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Four '
          'tables holding four different numbers, none of them empty, need '
          'at least 1 and 2 and 3 and 4 guests, which is 10, and there are '
          'six. No seating of six can do it and none ever could. The sweep '
          'agrees: none of the 203.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
