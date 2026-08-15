import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Even Chance',
      kind: 'exact',
      num: 1,
      den: 2,
      ways: 4,
      note: 'A flag is right exactly one time in two on four settings of the 225, '
          'each a test as sure as the fever is rare: one in ten with the test '
          'nine in ten each way, one in twenty with nineteen in twenty, one in a '
          'hundred with ninety-nine in a hundred, one in a thousand with nine '
          'hundred and ninety-nine; in a village of ten million with the fever '
          'one in a hundred, 99,000 ill are flagged and 99,000 well.',
    ),
    Level(
      name: 'The Doubtful Flag',
      kind: 'under',
      num: 1,
      den: 10,
      ways: 40,
      note: 'Forty settings leave a flag right fewer than one time in ten, and the '
          'famous one is among them: the fever one in a thousand and the test '
          'ninety-nine in a hundred both ways, 9,900 ill flagged against 99,900 '
          'well, 11 in 122, nine in a hundred and a hair.',
    ),
    Level(
      name: 'The Rare Fever, Trusted',
      kind: 'atLeast',
      num: 9,
      den: 10,
      prevalence: 1000,
      ways: 5,
      note: 'With the fever one in a thousand, a flag right nine times in ten '
          'takes a test that never flags the well, whatever it catches: five '
          'settings, all with the alarm at none, and even a false alarm of one in '
          'a thousand pulls the flag down to one time in two.',
    ),
    Level(
      name: 'The Coin Toss Fever',
      kind: 'exact',
      num: 1,
      den: 2,
      prevalence: 1000,
      ways: 1,
      note: 'The fever one in a thousand and a flag right one time in two is one '
          'setting: the test catching nine hundred and ninety-nine in a thousand '
          'and flagging the well one in a thousand, 9,990 ill flagged against '
          '9,990 well in the ten million.',
    ),
    Level(
      name: 'The Sure Flag',
      kind: 'sureWithAlarm',
      ways: 0,
      note: 'A flag is right every time only when no well villager is ever flagged, '
          'and the well outnumber the ill on every setting, so a test that flags '
          'even one in a thousand of them flags thousands of the well among the '
          'ten million: 45 settings make the flag sure, every one with the alarm '
          'at none, and none of the 225 with an alarm at all.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
