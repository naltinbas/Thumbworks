import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Minority Wins',
      map: 'BBRRRBBRRRBBRRRBBRRRBBRRR',
      kind: 'blue',
      wins: 3,
      ways: 276,
      note: 'Ten Blues in the two left columns against fifteen Reds: 276 of the '
          '4,006 drawings hand the Blues three wards, 232 of them with three, '
          'three and four Blues in the won wards and the Reds packed into two '
          'wards of their own, 44 with three, three and three and one Blue '
          'stranded; 3,033 drawings give the Blues two wards and 696 one, and one '
          'drawing none, the columns.',
    ),
    Level(
      name: 'The Sweep',
      map: 'BBBBBBBBBBBBBBBRRRRRRRRRR',
      kind: 'blue',
      wins: 5,
      ways: 1,
      note: 'Fifteen Blues in the top three rows against ten Reds: one drawing of '
          'the 4,006 gives the Blues all five wards, the five columns, three '
          'Blues and two Reds in each; 696 drawings give four wards, 3,033 three '
          'and 276 two, never fewer.',
    ),
    Level(
      name: 'The Majority Loses',
      map: 'BBBBBBBBBBBBBBBRRRRRRRRRR',
      kind: 'red',
      wins: 3,
      ways: 276,
      note: 'The same parish, fifteen Blues to ten Reds, and 276 drawings hand the '
          'Reds three wards, 232 of them with the Blues packed five and five into '
          'two wards and the Reds taking the other three by three votes to two, '
          'two and one, 44 with the Blues packed five and four; the Reds never '
          'take a fourth.',
    ),
    Level(
      name: 'The Nine',
      map: 'BRBRBRRRRRBRBRBRRRRRBRBRB',
      kind: 'blue',
      wins: 3,
      ways: 10,
      note: 'Nine Blues on the odd squares of the odd rows: ten drawings of the '
          '4,006 give them three wards, every one with exactly three Blues in each '
          'of the three, the rows among them; 490 give two, 2,124 one and 1,382 '
          'none.',
    ),
    Level(
      name: 'The Eight',
      map: 'BBBBBBBBRRRRRRRRRRRRRRRRR',
      kind: 'blue',
      wins: 3,
      ways: 0,
      note: 'Eight Blues, and a ward is won with three votes: three wards take nine, '
          'so eight Blues win two wards at the most, 1,916 drawings of the 4,006, '
          'one ward in 2,072 and none in 18, and never three.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
