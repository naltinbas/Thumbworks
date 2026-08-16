import 'level.dart';
import 'rules.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Green',
      village: Rules.green,
      ways: 78,
      note: 'Nine places in three rows, twelve streets, and 4,096 ways to '
          'point them, of which 78 leave the green one-way throughout. The '
          'ask opens five turns from the nearest of them, which is as far '
          'off as any orientation of the green gets.',
    ),
    Level(
      name: 'The Square',
      village: Rules.square,
      ways: 2,
      note: 'Four places round a square. Only two of the sixteen ways to '
          'point the streets work, and they are the two that send you round '
          'and round: any other leaves a place you can enter and never '
          'leave, or leave and never enter.',
    ),
    Level(
      name: 'The House',
      village: Rules.house,
      ways: 6,
      note: 'A square with a roof on it: two rounds sharing a street. Six '
          'of the 64 orientations work. The shared street may point either '
          'way, and once it does the two rounds have to run with it, which '
          'is why six and not eight.',
    ),
    Level(
      name: 'The Two Rings',
      village: Rules.rings,
      ways: 426,
      note: 'Eight places, an outer ring and an inner one with four streets '
          'between them, and 426 of the 4,096 orientations leave it one-way '
          'throughout, more than any other village here. It is the graph of '
          'a cube, and the ask opens four turns from the nearest answer.',
    ),
    Level(
      name: 'The Toll Lane',
      village: Rules.toll,
      ways: 0,
      note: 'Hopeless, and the tile says so. Two hamlets of three places '
          'each, joined by one lane. Point that lane whichever way you like '
          'and the hamlet at its far end can be reached but never left, so '
          'nine of the thirty ordered pairs go one way only and 21 is the '
          'most any orientation gets. Robbins said so in 1939: a village can '
          'be made one-way throughout exactly when no street is a bridge, '
          'and this lane is one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
