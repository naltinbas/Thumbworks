import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Even Fair',
      kind: 'even',
      ways: 171,
      note: 'The two averages agree exactly when everyone has the same '
          'number of friends: 171 plans of the 32,767 with a friendship in '
          'them do it, fifteen of three pairs, seventy rings and pairs of '
          'trios, seventy of three friends each, fifteen of four and the one '
          'of five, and on every other plan the friends named have more.',
    ),
    Level(
      name: 'The Gap of One',
      kind: 'one',
      ways: 155,
      note: 'The friends named have one friend more, on average, than '
          'people do on 155 plans; the gap is the spread of the counts over '
          'their average, so a gap of one means the counts spread as much '
          'as they average, and the commonest gap of all, on 5,742 plans, '
          'is a third.',
    ),
    Level(
      name: 'The Widest Gap',
      kind: 'widest',
      ways: 6,
      note: 'The gap is widest, 1 1/3, on the six stars, one person friends '
          'with all five and the five with nobody else: people average 1 '
          '2/3 friends, but the friends named, the star five times over and '
          'each of the others once, average 3.',
    ),
    Level(
      name: 'The Half',
      kind: 'half',
      ways: 1080,
      note: 'A gap of a half comes on 1,080 plans, and of a quarter on only '
          '80; 41 different gaps come in all, from nought to 1 1/3, and '
          'every one is nought or more, on all 32,767 plans with a '
          'friendship.',
    ),
    Level(
      name: 'The Popular Few',
      kind: 'under',
      ways: 0,
      note: 'Hopeless, and the tile says so. Name every friendship from both '
          'ends and take down the named friend\'s count each time: a person '
          'with k friends is named k times, so the friends\' average is the '
          'sum of the squares of the counts over the sum of the counts, and '
          'that is the plain average plus the spread of the counts over it, '
          'and a spread is never below nought. Feld set it down in 1991: '
          'your friends have more friends than you do, on average, and '
          'never fewer. The sweep of all 32,767 plans finds the two '
          'averages agreeing wherever everyone has the same number of '
          'friends and the friends named ahead everywhere else, and it '
          'finds the same person by person, each person\'s own friends '
          'averaged and those averages averaged, on all 32,767 as well.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
