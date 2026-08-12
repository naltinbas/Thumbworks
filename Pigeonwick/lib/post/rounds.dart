import 'round.dart';

/// The five rounds that ship.
///
/// Every number here is checked three ways before the bake: the
/// sweep, the recurrence and the figure by e, and
/// tool/check_rounds.dart refuses the lot if anything disagrees.
class Rounds {
  static const all = [
    Round(
      name: 'The Two Away',
      letters: 3,
      home: 0,
      ways: 2,
      note: 'Three letters go all-wrong two ways, one for each '
          'turn of the circle: pass every letter left, or pass '
          'every letter right.',
    ),
    Round(
      name: 'The Nine',
      letters: 4,
      home: 0,
      ways: 9,
      note: 'Nine of the 24 rounds of four keep every letter '
          'out: the recurrence says three times the pair before, '
          'three times two plus one, and the figure of 4! over e '
          'lands on nine as well.',
    ),
    Round(
      name: 'The Forty-Four',
      letters: 5,
      home: 0,
      ways: 44,
      note: 'Five letters, 120 rounds, 44 all-wrong: four times '
          'nine-and-two, as the recurrence has it, and 5! over e '
          'rounds to the same.',
    ),
    Round(
      name: 'The One Home',
      letters: 4,
      home: 1,
      ways: 8,
      note: 'Exactly one home is four choices of the lucky '
          'letter times the two all-wrong rounds of the other '
          'three: eight, which the sweep confirms.',
    ),
    Round(
      name: 'The Three Home',
      letters: 4,
      home: 3,
      ways: 0,
      note: 'Three letters home of four leaves the fourth one '
          'hole, its own: three home is four home, and exactly '
          'three is nobody\'s round. The sweep read all 24 and '
          'found the count goes 9, 8, 6, none, 1.',
    ),
  ];

  static int get count => all.length;

  static Round at(int number) => all[number];
}
