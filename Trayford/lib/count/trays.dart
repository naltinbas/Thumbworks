import 'tray.dart';

/// The five trays that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every count in the tray, Sun Tzu's construction held to it, and
/// tool/check_counts.dart refuses the lot if anything disagrees.
class Trays {
  static const all = [
    Tray(
      name: 'The Threes and Fives',
      rows: [3, 5],
      asked: [2, 4],
      ways: 2,
      note: 'Fourteen and twenty-nine, fifteen apart, and every asking '
          'by threes and fives is met by exactly one count below '
          'fifteen.',
    ),
    Tray(
      name: 'The Old Count',
      rows: [3, 5, 7],
      asked: [2, 3, 2],
      ways: 1,
      note: 'Sun Tzu\'s own asking, and twenty-three is its answer, the '
          'one count below a hundred and five; the construction gives '
          'it with no searching, 140 plus 63 plus 30 over 105.',
    ),
    Tray(
      name: 'The Fives and Sevens',
      rows: [5, 7],
      asked: [3, 4],
      ways: 1,
      note: 'Eighteen alone in the tray, the one count below '
          'thirty-five, and every one of the 35 askings by fives and '
          'sevens is met exactly once below thirty-five.',
    ),
    Tray(
      name: 'The Fours and Sixes',
      rows: [4, 6],
      asked: [1, 3],
      ways: 2,
      note: 'Nine and twenty-one, twelve apart: fours and sixes share '
          'a factor of two, so the leftovers must agree on it, both '
          'odd here, and only 12 of the 24 askings can be met at all.',
    ),
    Tray(
      name: 'The Odd and Even',
      rows: [4, 6],
      asked: [1, 2],
      ways: 0,
      note: 'One over by fours is odd, two over by sixes is even, and no '
          'count is both; the sweep of the tray finds none, and the '
          'shared factor said so first.',
    ),
  ];

  static int get count => all.length;

  static Tray at(int number) => all[number];
}
