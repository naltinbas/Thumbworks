import 'level.dart';

/// The five cellars that ship.
///
/// Every number here is checked before the bake: the game tree walked
/// for every row up to two hundred casks, the bound held to it, every
/// first cut swept, and tool/check_cuts.dart refuses the lot if
/// anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Eight',
      casks: 8,
      questions: 3,
      ways: 1,
      cuts: 7,
      note: 'Eight casks and three questions: cut in the middle every time, '
          'four, then two, then one, and the third answer names the cask. Cut '
          'anywhere else and the cellarman keeps five or more, which three '
          'questions never search: one first cut of the seven serves.',
    ),
    Level(
      name: 'The Sixteen',
      casks: 16,
      questions: 4,
      ways: 1,
      cuts: 15,
      note: 'Sixteen is two to the fourth, so four questions serve exactly, '
          'and only the middle cut serves first: eight, four, two, one.',
    ),
    Level(
      name: 'The Twenty',
      casks: 20,
      questions: 5,
      ways: 13,
      cuts: 19,
      note: 'Twenty casks and five questions, and five serve sixteen or fewer '
          'after the first answer, so any first cut leaving at most sixteen '
          'either side does: after four casks up to after sixteen, thirteen '
          'first cuts of the nineteen.',
    ),
    Level(
      name: 'The Hundred',
      casks: 100,
      questions: 7,
      ways: 29,
      cuts: 99,
      note: 'A hundred casks and seven questions: seven serve up to a hundred '
          'and twenty-eight, so the first cut may leave sixty-four either side, '
          'after thirty-six casks up to after sixty-four, twenty-nine of the '
          'ninety-nine, and the middle among them.',
    ),
    Level(
      name: 'The Nine',
      casks: 9,
      questions: 3,
      ways: 0,
      cuts: 8,
      note: 'Three questions have eight answers between them, yes or no three '
          'times over, and nine casks are one more than eight, so some two casks '
          'get the same three answers and are never told apart. Cut nine '
          'anywhere and the cellarman keeps five at least, and five in two '
          'questions is four answers for five casks again.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
