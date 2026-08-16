import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Yardstick of Five',
      kind: 'five',
      ways: 23,
      note: 'The yardstick is five, the fifth Fibonacci number, exactly when '
          'the two counts have five for their common measure: 23 settings '
          'of the 900, from 5 and 5 to 30 and 25; the yardstick is 8 on 19 '
          'settings, where the counts measure by six, and 55 on 7, where '
          'they measure by ten.',
    ),
    Level(
      name: 'The Sly Pair',
      kind: 'sly',
      ways: 114,
      note: 'The first two Fibonacci numbers are both one, so two hedges are '
          'coprime whenever their counts measure by one or by two: 698 of '
          'the 900 settings have coprime hedges, and 114 of them, the '
          'counts both above two, sly, the counts sharing a factor and the '
          'hedges none, 4 and 6 first, hedges 3 and 8.',
    ),
    Level(
      name: 'The Whole Measure',
      kind: 'whole',
      ways: 38,
      note: 'One Fibonacci number measures another exactly when its count '
          'divides the other\'s, the first two hedges of one aside: the '
          'third hedge, 2, measures every even-count hedge, and 38 settings '
          'have the first count from three up, below the second and '
          'dividing it, 3 and 6 first; a hedge of prime count is prime on '
          'seven of the ten prime counts to thirty, and 19 fails, 4,181 '
          'being 37 times 113, while the fourth hedge, 3, is prime with a '
          'count that is not.',
    ),
    Level(
      name: 'The Long Yardstick',
      kind: 'long',
      ways: 37,
      note: 'A yardstick of 55 or longer wants the counts to measure by ten '
          'at least, 37 settings, 10 and 10 first; the longest of all is '
          '832,040 itself, both counts thirty, and 30 and 15 measure by '
          '610.',
    ),
    Level(
      name: 'The Odd Share',
      kind: 'odd',
      ways: 0,
      note: 'Hopeless, and the tile says so. Two Fibonacci numbers share '
          'exactly the factors their counts share, since the (m + n)th is '
          'the (m - 1)th times the nth plus the mth times the (n + 1)th, '
          'so any factor common to the mth and the nth is common to the mth '
          'and the (n - m)th, and Euclid runs on the counts as it runs on '
          'the hedges; Lucas set it down in 1876. Counts that share no '
          'factor come down to one and one, and the yardstick is the first '
          'hedge, one. The sweep of all 900 settings finds the yardstick '
          'by Euclid on the hedges themselves and by the count it measures, '
          'agreeing on every one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
