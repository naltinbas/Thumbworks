import 'grind.dart';

/// The five grinds that ship.
///
/// Every number here is checked before the bake: the ledger, the
/// grinding and the sweep, and tool/check_mills.dart refuses the
/// lot if anything disagrees.
class Grinds {
  static const all = [
    Grind(
      name: 'The First Nought',
      asked: 1,
      ways: 5,
      note: 'The first nought arrives at five, when the five '
          'meets a two, and stays through nine: five windings, '
          'like every count below the top.',
    ),
    Grind(
      name: 'The Four',
      asked: 4,
      ways: 5,
      note: 'Twenty through twenty-four grind four noughts: one '
          'for each five wound past. The next winding is '
          'another story.',
    ),
    Grind(
      name: 'The Six',
      asked: 6,
      ways: 5,
      note: 'Twenty-five brings two fives in one winding, so '
          'the count leaps from four to six: the five it never '
          'lands on is the game\'s last grind.',
    ),
    Grind(
      name: 'The Hundred\'s Count',
      asked: 24,
      ways: 5,
      note: 'The famous one: a hundred factorial ends in '
          'twenty-four noughts, twenty from the fives, four '
          'more from the twenty-fives, and a hundred through a '
          'hundred and four all agree.',
    ),
    Grind(
      name: 'The Fifth Nought',
      asked: 5,
      ways: 0,
      note: 'No winding ends in exactly five noughts: '
          'twenty-four grinds four, and twenty-five brings its '
          'second five along, grinding six. The skipped counts '
          'march on past it, 5, 11, 17, 23, 29, one at every '
          'twenty-five.',
    ),
  ];

  static int get count => all.length;

  static Grind at(int number) => all[number];
}
