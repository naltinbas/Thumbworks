import 'wick.dart';

/// The boards that ship.
///
/// Every number here is checked twice over: tool/check_wicks.dart works
/// each one out from the crosses and refuses the bake if a written
/// figure is wrong, and the suite executes the answers besides.
class Wicks {
  static const all = [
    Wick(
      name: 'The First Lamp',
      rows: 3,
      cols: 3,
      // .#./###/.#. : exactly one press made this, so one unmakes it.
      lit: 0xBA,
      fewest: 1,
      ways: 1,
    ),
    Wick(
      name: 'The Four Corners',
      rows: 3,
      cols: 3,
      // #.#/.../#.#
      lit: 0x145,
      fewest: 4,
      ways: 1,
    ),
    Wick(
      name: 'The Nine',
      rows: 3,
      cols: 3,
      lit: 0x1FF,
      fewest: 5,
      ways: 1,
      note:
          'On a board of nine every press-set makes a different board, '
          'so each board has exactly one, and the walk of all five '
          'hundred and twelve agrees with the algebra on every count.',
    ),
    Wick(
      name: 'The Lamplit Ring',
      rows: 4,
      cols: 4,
      // .##./#..#/#..#/.##.
      lit: 0x6996,
      fewest: 4,
      ways: 16,
      note:
          'A board of sixteen keeps four quiet patterns, presses that '
          'change nothing at all, and every sum of them shifts one '
          'answer into another: two to the fourth is the sixteen.',
    ),
    Wick(
      name: 'The Full Five',
      rows: 5,
      cols: 5,
      lit: 0x1FFFFFF,
      fewest: 15,
      ways: 4,
      note:
          'The classic: every lamp lit, and no way home shorter than '
          'fifteen presses. Four press-sets do it, and all four weigh '
          'fifteen exactly.',
    ),
    Wick(
      name: 'The Unquenchable',
      rows: 5,
      cols: 5,
      lit: 0x1,
      fewest: null,
      ways: 0,
      note:
          'Of the twenty five lamps only five could stand alone and '
          'go dark, the middle and the four a diagonal step from it, and '
          'the '
          'corner is not among them.',
    ),
  ];

  static int get count => all.length;

  static Wick at(int number) => all[number];
}
