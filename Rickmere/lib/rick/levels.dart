import 'level.dart';

/// The five asks, first to last. Each count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Square Corner',
      kind: 'square',
      ways: 596,
      fewest: 1,
      note: '596 fields of the 2,148 the green holds have a square corner, '
          'which is more than a quarter of them. The ricks do not care: the '
          'markers come out evenly spread on all 2,148, square corner or no.',
    ),
    Level(
      name: 'Six Acres',
      kind: 'six',
      ways: 68,
      fewest: 2,
      note: '68 fields of the 2,148 are six acres. Areas on a peg green are '
          'always whole half acres, which is Pick counting the pegs, and six '
          'is the largest that still leaves plenty of room to move.',
    ),
    Level(
      name: 'The Square Six',
      kind: 'squaresix',
      ways: 16,
      fewest: 3,
      note: '16 fields of the 2,148 have a square corner and six acres both. '
          'The legs have to multiply to twelve, so they are 3 and 4 or 4 and '
          '3, and the green holds sixteen ways to lay that down.',
    ),
    Level(
      name: 'The Widest Ring',
      kind: 'widest',
      ways: 4,
      fewest: 3,
      note: '4 fields of the 2,148 spread the markers as far as the green '
          'allows, and they are the four right triangles that take up a whole '
          'corner of it. The markers then stand (32 and 16 roots of three) '
          'over 3 apart, squared, which is about 19.9.',
    ),
    Level(
      name: 'The Uneven Three',
      kind: 'uneven',
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Every one '
          'of the 2,148 fields the green holds was measured before the sham '
          'was built, with the ricks raised outward and again inward, and on '
          'all 4,296 the three markers came out the same distance apart. '
          'Rutherford printed the fact in The Ladies\' Diary in 1825, and it '
          'has carried Napoleon\'s name ever since.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
