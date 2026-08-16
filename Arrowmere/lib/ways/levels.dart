import 'level.dart';
import 'rules.dart';

/// The five asks, first to last. Each ways count is the sweep's, and the
/// checker refuses the bake if one drifts. The numbers inside the notes
/// are the same sweep's, written out by hand.
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
          'of the 64 orientations work. Three ways run between C and D, the '
          'street they share, the roof through E, and the far side of the '
          'square through B and A, and each has to run one way from end to '
          'end. That is eight, and the two that send all three the same way '
          'leave a place that can be reached but never left, which is why '
          'six and not eight.',
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
      note: 'Hopeless, and the card at the end of the ask says so. Two '
          'hamlets of three places each, joined by one lane. Point that lane '
          'whichever way you like and the hamlet at its far end can be '
          'reached but never left, so the nine pairs of places across the '
          'lane can be got between one way only, and 21 of the thirty '
          'ordered pairs is the most any orientation gets. Robbins said so '
          'in 1939: a joined village can be made one-way throughout exactly '
          'when no street is a bridge, and this lane is one.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
