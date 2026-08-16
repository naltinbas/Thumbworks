import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Seven',
      clock: 7,
      kind: 'all',
      ways: 2,
      note: 'Seven has two full bases of its six, 3 and 5: 3 walks 1, 3, 2, 6, 4, '
          '5, and 5 walks the same hours backwards, 1, 5, 4, 6, 2, 3, since 3 '
          'times 5 is one more than 14; 2 and 4 come home on the third step, '
          '6 on the second, and 1 stays put. Two full bases is phi of six, and '
          'every prime clock has phi of one less: four on eleven, four on '
          'thirteen, eight on seventeen.',
    ),
    Level(
      name: 'The Fourth Home',
      kind: 'four',
      ways: 20,
      note: 'Twenty settings of the 275 come home on the fourth step and not '
          'before: two bases each on the clocks of five, ten, thirteen and '
          'seventeen and four each on fifteen, sixteen and twenty. Their second '
          'step is a square root of 1 other than 1, one short of the clock on '
          'five, ten, thirteen and seventeen, 4, 9, 12 and 16, and 4 on '
          'fifteen, 9 on sixteen and 9 on twenty for all four bases each; 2 on '
          'five walks 1, 2, 4, 3.',
    ),
    Level(
      name: 'The Full Round',
      least: 10,
      kind: 'all',
      ways: 32,
      note: 'Thirty-two settings land it, all on prime clocks: four bases on '
          'eleven and on thirteen, eight on seventeen, six on nineteen and ten '
          'on twenty-three, phi of one less each time. No base touches every '
          'hour but 0 of a clock that is not prime, since an hour sharing a '
          'factor with the clock is never reached from 1 by multiplying. 2 on '
          'eleven walks 1, 2, 4, 8, 5, 10, 9, 7, 3, 6, and 5 on twenty-three '
          'takes the longest walk the dials hold, twenty-two hours, the first '
          'of ten bases that do.',
    ),
    Level(
      name: 'The Nine',
      clock: 9,
      kind: 'units',
      ways: 2,
      note: 'Nine has two full bases of its eight, 2 and 5: 2 walks 1, 2, 4, 8, '
          '7, 5, and 5 walks it backwards, 1, 5, 7, 8, 4, 2; 4 and 7 come home '
          'on the third step, 8 on the second, and 3 and 6, sharing a factor '
          'with nine, fall to 0 and never come home. Nine is a power of an odd '
          'prime, one of the clocks Gauss\'s rule gives a full base: fifteen '
          'of the twenty-two clocks on the dial have one, and 8, 12, 15, 16, '
          '20, 21 and 24 have none.',
    ),
    Level(
      name: 'The Eight',
      clock: 8,
      kind: 'units',
      ways: 0,
      note: 'Hopeless, and the tile says so. Every odd number squared is one more '
          'than a multiple of eight, 1, 9, 25 and 49, so 3, 5 and 7 come home '
          'on the second step, touching two odd hours of the four, and 1 stays '
          'put; 2, 4 and 6 fall to 0 and never come home. Eight is the smallest '
          'clock with no full base, and 12, 15, 16, 20, 21 and 24 follow it on '
          'the dials, none of them 2, 4, a power of an odd prime or twice one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
