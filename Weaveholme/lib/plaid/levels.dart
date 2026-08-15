import 'level.dart';

/// The five plaids that ship.
///
/// Every number here is checked before the bake: every filling of the
/// two and the four swept whole, the eight walked row by row, every
/// triple of rows of six swept, and tool/check_weaves.dart refuses the
/// lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Two',
      size: 2,
      given: [],
      ways: 8,
      fillings: 16,
      note: 'Two rows of two, to agree in one square: eight fillings of the '
          'sixteen, since once the first row is set, four ways, the second may '
          'be either of the two rows that agree with it in one square.',
    ),
    Level(
      name: 'The Four',
      size: 4,
      given: [],
      ways: 768,
      fillings: 65536,
      note: 'Four rows of four, every two agreeing in two squares: 768 fillings '
          'of the 65,536, and one of them Sylvester\'s, made of the two by two '
          'laid out four times with the last quarter turned light for dark.',
    ),
    Level(
      name: 'The Eight, Two Rows',
      size: 8,
      given: [0, 170, 204, 102, 240, 90],
      ways: 8,
      fillings: 65536,
      note: 'Six rows of Sylvester\'s eight given and two to weave: eight '
          'fillings of the 65,536 land, since each row to come has two squares '
          'free of the rows above and its mate is fixed by it.',
    ),
    Level(
      name: 'The Eight, Four Rows',
      size: 8,
      given: [0, 170, 204, 102],
      ways: 768,
      fillings: 4294967296,
      note: 'Four rows of Sylvester\'s eight given and four to weave: the walk '
          'holds each new row against the rows above and finds 768 fillings of '
          'the 4,294,967,296.',
    ),
    Level(
      name: 'The Six',
      size: 6,
      given: [],
      ways: 0,
      fillings: 68719476736,
      note: 'Six rows of six, every two to agree in three squares, and no three '
          'rows can: turn whole columns till the first row is all light, which '
          'changes no agreement, and the other two rows have three light each; '
          'where both are light, say a squares, and both dark, b, the second\'s '
          'lights are a plus the third\'s darks that it lights, and the third\'s '
          'darks are b plus those, so a equals b, and the two agree in a plus b, '
          'an even count, never three. Every triple of rows of six was swept, '
          '262,144 of them, and none agrees pairwise in three.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
