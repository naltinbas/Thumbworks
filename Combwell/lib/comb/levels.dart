import 'level.dart';

/// The five combs that ship.
///
/// Every number here is checked before the bake: every filling of every
/// comb walked, forced cell by forced cell, the twelve fillings of the
/// whole comb held to be the one comb turned and reflected, and
/// tool/check_fillings.dart refuses the lot if anything disagrees.
class Levels {
  /// The comb Adams found in 1957, row by row from the top left.
  static const adams = [3, 17, 18, 19, 7, 1, 11, 16, 2, 5, 6, 9, 12, 4, 8, 14, 10, 13, 15];

  static const all = [
    Level(
      name: 'The Last Four',
      sum: 38,
      given: [3, 17, 18, 19, 7, 1, 11, 16, 0, 0, 0, 9, 12, 0, 8, 14, 10, 13, 15],
      ways: 1,
      note: 'Fifteen cells given and four to fill, the middle of the comb: '
          'every line through an empty cell has one empty cell only, so each is '
          'forced by the sum, and one filling lands.',
    ),
    Level(
      name: 'The Last Seven',
      sum: 38,
      given: [3, 17, 18, 19, 0, 0, 11, 16, 0, 0, 0, 9, 12, 0, 0, 14, 10, 13, 15],
      ways: 1,
      note: 'Twelve given and seven to fill: the numbers left are 1, 2, 4, 5, 6, '
          '7 and 8, and the lines force them one after another; one filling '
          'lands.',
    ),
    Level(
      name: 'The Last Ten',
      sum: 38,
      given: [3, 0, 18, 19, 0, 0, 0, 16, 0, 0, 0, 9, 12, 0, 0, 0, 10, 13, 15],
      ways: 1,
      note: 'Nine given and ten to fill, and still one filling: the walk finds '
          'no other way to place the ten numbers left so that all fifteen lines '
          'sum to 38.',
    ),
    Level(
      name: 'The Whole Comb',
      sum: 38,
      given: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ways: 12,
      note: 'Nothing given: the walk fills the comb every way and finds twelve '
          'fillings, and they are one comb in its six turnings and their six '
          'reflections, the comb Clifford Adams found in 1957 after forty-seven '
          'years of trying: 3, 17, 18 across the top, 19, 7, 1, 11 below, 16, 2, '
          '5, 6, 9 through the middle, 12, 4, 8, 14, and 10, 13, 15 along the '
          'bottom.',
    ),
    Level(
      name: 'The Thirty-Seven',
      sum: 37,
      given: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ways: 0,
      note: 'The five rows of the comb take every number from one to nineteen '
          'exactly once, 190 in all, so if the rows are to sum alike each sums '
          '38, and no comb ever sums to 37; the walk fills it every way and '
          'finds none, and none for 39 either.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
