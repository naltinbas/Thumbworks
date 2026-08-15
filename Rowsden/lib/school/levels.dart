import 'level.dart';

/// The five weeks that ship.
///
/// Every number here is checked before the bake: every filling swept,
/// Kirkman's own week held to it, and tool/check_walks.dart refuses the
/// lot if anything disagrees.
class Levels {
  static const rows = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
  ];
  static const columns = [
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
  ];
  static const diagonals = [
    [0, 4, 8],
    [1, 5, 6],
    [2, 3, 7],
  ];

  static const all = [
    Level(
      name: 'The Second Day',
      given: [rows],
      more: 1,
      ways: 36,
      fillings: 280,
      note: 'The first day walks the girls in three rows of three; a second '
          'day must part every row. Of the 280 ways to walk nine out in rows '
          'of three, 36 do it: every girl must take one from each of the '
          'other two rows, and 36 is 6 times 6.',
    ),
    Level(
      name: 'The Third Day',
      given: [rows, columns],
      more: 1,
      ways: 2,
      fillings: 280,
      note: 'Rows and columns of a three-by-three walked, a third day must '
          'take one girl from each row and each column: a diagonal set, and '
          'there are two of those, the two ways of slanting. 2 of the 280.',
    ),
    Level(
      name: 'The Fourth Day',
      given: [rows, columns, diagonals],
      more: 1,
      ways: 1,
      fillings: 280,
      note: 'Three days walked leave nine pairs unmet, and they fall into '
          'three rows exactly one way, the other slant. 1 of the 280, and '
          'the week is Kirkman\'s, the affine plane of order three.',
    ),
    Level(
      name: 'The Whole Week',
      given: [rows],
      more: 3,
      ways: 72,
      fillings: 21952000,
      note: 'Thirty-six pairs, nine a day, four days: from the first day given, '
          '36 second days, then 2 third days each, then 1 fourth, 72 weeks of '
          'the 21,952,000 fillings, and every one covers all 36 pairs.',
    ),
    Level(
      name: 'The Three Days',
      given: [rows],
      more: 2,
      allPairs: true,
      ways: 0,
      fillings: 78400,
      note: 'Each girl walks with two others a day and has eight to meet, so '
          'she needs four days, and three days meet 27 pairs of the 36 at the '
          'most. Every filling of two more days, 78,400 of them, was walked '
          'to be sure: 72 repeat no pair, and none covers every pair.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
