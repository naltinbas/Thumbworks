import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Alabama Paradox',
      hamlets: ['Ash', 'Beck', 'Cote'],
      pops: [6, 6, 2],
      kind: 'alabama',
      ways: 4,
      note: 'Ash and Beck of six hundred and Cote of two: at ten seats the quotas '
          'are 4 2/7, 4 2/7 and 1 3/7, the floors take nine and Cote\'s fraction '
          'is largest, so the shares are 4, 4, 2; at eleven the quotas are 4 5/7, '
          '4 5/7 and 1 4/7, the floors take nine and the two seats left go to Ash '
          'and Beck, 5, 5, 1, and Cote loses a seat as the moot grows. It happens '
          'at 3, 10, 17 and 24 seats, four moots of the 29, and at three seats '
          'Cote\'s one seat falls to none.',
    ),
    Level(
      name: 'The Four Hamlets',
      hamlets: ['Ash', 'Beck', 'Cote', 'Dale'],
      pops: [12, 7, 4, 2],
      kind: 'alabama',
      ways: 1,
      note: 'Four hamlets of twelve, seven, four and two hundred: only the moot of '
          'nineteen seats loses a hamlet a seat as it grows, 9, 5, 3, 2 at nineteen '
          'and 10, 6, 3, 1 at twenty, Dale the loser.',
    ),
    Level(
      name: 'The Broken Quota',
      hamlets: ['Ash', 'Beck', 'Cote'],
      pops: [5, 3, 1],
      kind: 'overQuota',
      ways: 3,
      note: 'Dealt one at a time by Jefferson\'s rule, seven seats among five, three '
          'and one hundred go 5, 2, 0, though Ash\'s quota is 3 8/9 and rounds up '
          'to four: the largest hamlet is dealt more than its quota, at 7, 16 and '
          '25 seats; largest remainders never break the quota, 4, 2, 1 at seven.',
    ),
    Level(
      name: 'The Whole Shares',
      hamlets: ['Ash', 'Beck', 'Cote'],
      pops: [6, 6, 2],
      kind: 'whole',
      ways: 4,
      note: 'With the populations six, six and two hundred, fourteen in all, the '
          'quotas come whole when the seats are a multiple of seven, 7, 14, 21 and '
          '28, four moots; then largest remainders and the dealing agree, 3, 3, 1 '
          'at seven.',
    ),
    Level(
      name: 'The Jefferson Paradox',
      hamlets: ['Ash', 'Beck', 'Cote'],
      pops: [6, 6, 2],
      kind: 'jefferson',
      ways: 0,
      note: 'Jefferson\'s rule deals the seats one at a time, each to the hamlet '
          'whose population per seat, counting the seat it would get, is largest, '
          'and a seat once dealt is never taken back; so a moot of one more seat '
          'is the same dealing with one more seat dealt, and no hamlet loses. On '
          'none of the 29 moots does a hamlet fall, and the dealing agrees with the '
          'divisor reading on every one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
