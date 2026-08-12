import 'green.dart';

/// The five greens that ship.
///
/// Every number here is checked three ways before the bake: the
/// pair ledger, the lantern arithmetic and the search, and
/// tool/check_greens.dart refuses the lot if any two disagree.
class Greens {
  static const all = [
    Green(
      name: 'The First Rope',
      lanterns: 3,
      given: [],
      ways: 1,
      note: 'Three lanterns hold three pairs and one rope holds '
          'all three: the smallest green closes at a stroke, and '
          'the search counts exactly one way.',
    ),
    Green(
      name: 'The Two Ways',
      lanterns: 7,
      given: [(0, 1, 2), (0, 3, 4)],
      ways: 2,
      note: 'Five ropes to string and exactly two closings to '
          'find: the two given ropes force nearly everything '
          'else, and the search knows both ends from here.',
    ),
    Green(
      name: 'The One Way',
      lanterns: 7,
      given: [(0, 1, 2), (0, 3, 4), (0, 5, 6), (1, 3, 5)],
      ways: 1,
      note: 'Four ropes given leave one closing and one only: '
          'every remaining rope is forced, though the forcing '
          'takes finding.',
    ),
    Green(
      name: 'The Seven Ropes',
      lanterns: 7,
      given: [],
      ways: 30,
      note: 'From a bare green the search strings exactly 30 '
          'closings, and every one is the same seven-rope figure '
          'worn thirty ways: seven lanterns, seven ropes, three '
          'to a rope and three at every lantern.',
    ),
    Green(
      name: 'The Six Lanterns',
      lanterns: 6,
      given: [],
      ways: 0,
      note: 'Fifteen pairs divide neatly into five ropes, and '
          'still no roping closes: each lantern must share a rope '
          'with five others, two at a time, and two and a half '
          'ropes is nobody\'s count. The search says the same the '
          'long way, finding no closing among all the ropings of '
          'six.',
    ),
  ];

  static int get count => all.length;

  static Green at(int number) => all[number];
}
