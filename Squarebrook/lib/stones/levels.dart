import 'level.dart';

/// The five numbers that ship.
///
/// Every number here is checked before the bake: every picking of
/// stones swept for every number on the sham, every number to a
/// thousand made with the fewest squares, Lagrange and Legendre held to
/// the sweep, and tool/check_pickings.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'Twelve in Three',
      number: 12,
      count: 3,
      ways: 1,
      pickings: 10,
      note: 'Three stones from one, four and nine: four and four and four, and '
          'no other picking of the ten makes twelve.',
    ),
    Level(
      name: 'Fifty in Two',
      number: 50,
      count: 2,
      ways: 2,
      pickings: 28,
      note: 'Two stones from the seven up to forty-nine: one and forty-nine, or '
          'twenty-five and twenty-five, two pickings of the twenty-eight, fifty '
          'being the smallest number that is two squares two ways.',
    ),
    Level(
      name: 'Twenty-Three in Four',
      number: 23,
      count: 4,
      ways: 1,
      pickings: 35,
      note: 'Twenty-three is seven more than sixteen, so three squares never '
          'make it, and four do one way of thirty-five: nine, nine, four and '
          'one. Every number is four squares at most, as Lagrange proved in '
          '1770, and the sweep finds four enough for every number to a '
          'thousand.',
    ),
    Level(
      name: 'Ninety-Nine in Three',
      number: 99,
      count: 3,
      ways: 3,
      pickings: 165,
      note: 'Three stones from the nine up to eighty-one, three ways of the 165: '
          'one, forty-nine and forty-nine; nine, nine and eighty-one; and '
          'twenty-five, twenty-five and forty-nine.',
    ),
    Level(
      name: 'Seven in Three',
      number: 7,
      count: 3,
      ways: 0,
      pickings: 4,
      note: 'A square leaves nought, one or four when divided by eight, and no '
          'three of those add to seven, so seven is never three squares, nor '
          'fifteen, nor twenty-three, nor any number seven more than a multiple '
          'of eight, nor four times one of those; of the four pickings of three '
          'from one and four, none makes seven, and it wants four: four, one, one '
          'and one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
