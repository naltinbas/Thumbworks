import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static final all = <Level>[
    Level(
      name: 'The Clean Lead',
      ash: 3,
      birch: 2,
      kind: 'ahead',
      ways: 2,
      note: 'Three Ash to two Birch, and Ash ahead after every ballot: '
          'A A A B B and A A B A B, two of the ten orders, which is one in '
          'five, the majority of one over the poll of five, just as '
          'Bertrand says. Start with a Birch ballot and he is behind at once, '
          'and A B A ... has him level after two.',
    ),
    Level(
      name: 'The Level Twice',
      ash: 4,
      birch: 3,
      kind: 'levels',
      count: 2,
      ways: 12,
      note: 'Four to three stands level twice in 12 of its 35 orders, once in '
          '10, three times in 8, and never in 5, those five being the orders '
          'that keep Ash ahead throughout, one in seven of the 35, the '
          'majority of one over the poll of seven.',
    ),
    Level(
      name: 'The Two Turns',
      ash: 5,
      birch: 3,
      kind: 'changes',
      count: 2,
      ways: 7,
      note: 'Five to three sees the lead change hands exactly twice in 7 of '
          'its 56 orders, once in 20, three times in 1 and never in 28; the '
          '14 that keep Ash ahead throughout are one in four, the majority '
          'of two over the poll of eight, and 28 never put him behind.',
    ),
    Level(
      name: 'The Never Behind',
      ash: 4,
      birch: 4,
      kind: 'neverBehind',
      ways: 14,
      note: 'Four to four never puts Ash behind, level allowed, in 14 of its '
          '70 orders: Catalan\'s fourteen, the formula (a - b + 1)/(a + 1) '
          'of the 70 with a and b both four. Every one of the 70 stands '
          'level at the end, and 16 stand level four times.',
    ),
    Level(
      name: 'The Level Poll',
      ash: 4,
      birch: 4,
      kind: 'ahead',
      ways: 0,
      note: 'Hopeless, and the tile says so. Four to four ends level, so no '
          'order keeps Ash ahead after the last ballot, whatever it did '
          'before: none of the 70, and Bertrand\'s majority of nought over '
          'the poll says nought.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
