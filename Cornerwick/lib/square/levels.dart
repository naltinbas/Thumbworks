import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Whole Centres',
      kind: 'whole',
      ways: 18528,
      note: 'A square\'s centre sits half a side along and half a side out '
          'from the side\'s middle, so it falls on a peg place exactly when '
          'the side runs an even count across and an even count up, or an '
          'odd and an odd; 18,528 of the 227,952 fours with no three pegs '
          'in a line put all four centres on peg places, and the pegs (1, '
          '1), (3, 1), (3, 3), (1, 3) put them at (2, 0), (4, 2), (2, 4) '
          'and (0, 2).',
    ),
    Level(
      name: 'The Square',
      kind: 'square',
      ways: 5192,
      note: 'The four centres make a square exactly when the four pegs are '
          'a parallelogram, as Thebault showed in 1937: 5,192 fours with no '
          'three in a line do it, and the sweep finds no square of centres '
          'on any other four; and a square walked the wrong way round, '
          'clockwise, folds its four squares inward and drops all four '
          'centres in one place, 200 fours of the 303,600 in all.',
    ),
    Level(
      name: 'The Meeting Peg',
      kind: 'meeting',
      ways: 31480,
      note: 'The two joins cross at right angles, and their crossing falls '
          'on a peg place for 31,480 of the 227,952 fours: the pegs (0, 0), '
          '(3, 1), (4, 4), (1, 3) join their centres by two lines six long '
          'crossing at (2, 2), the middle of the parallelogram.',
    ),
    Level(
      name: 'The Fives',
      kind: 'fives',
      ways: 2960,
      note: 'The two joins are of one length always, and five long on 2,960 '
          'fours; the commonest length is the root of two and a half, on '
          '24,320, and 42 lengths come in all, from nought, on 3,832 fours '
          'whose opposite centres fall together, up to eight, on the square '
          'of the whole board.',
    ),
    Level(
      name: 'The Skew Cross',
      kind: 'skew',
      ways: 0,
      note: 'Hopeless, and the tile says so. Call the four pegs A, B, C, D '
          'and the centres of the squares on AB, BC, CD and DA in turn P, '
          'Q, R and S: each centre is the two ends added and their gap '
          'turned a right angle, halved, and when the join from P to R is '
          'written out from the four pegs and turned a right angle, it is '
          'the join from Q to S, letter for letter, so the two joins are of '
          'one length and square to each other, whatever the pegs. Van '
          'Aubel proved it in 1878, and the sweep of all 303,600 ordered '
          'fours of pegs, three in a line or not, finds it so on every one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
