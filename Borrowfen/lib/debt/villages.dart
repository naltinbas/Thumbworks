import 'village.dart';

/// The five villages that ship.
///
/// Every number here is checked three ways before the bake:
/// the burning, the census, and the search, and
/// tool/check_villages.dart refuses the lot if any two disagree.
class Villages {
  static const all = [
    Village(
      name: 'The Lane',
      houseNames: ['the Gate', 'the Mill', 'the Barn'],
      roads: [(0, 1), (1, 2)],
      spots: [(0.12, 0.55), (0.5, 0.4), (0.88, 0.55)],
      spread: [-1, 2, -1],
      fewest: 1,
      note: 'A village with no ring round it holds a single class '
          'of spread, and any total short of nothing settles: the '
          'lane\'s census counts one tidy spread, and its one '
          'spanning tree is the lane itself.',
    ),
    Village(
      name: 'The Green',
      houseNames: ['the Well', 'the Forge', 'the Inn', 'the Church'],
      roads: [(0, 1), (1, 2), (2, 3), (3, 0)],
      spots: [(0.5, 0.14), (0.9, 0.5), (0.5, 0.86), (0.1, 0.5)],
      spread: [-1, -1, 2, 1],
      fewest: 2,
      note: 'One ring of roads makes the genus one, so a pound '
          'clear settles every one of the green\'s four classes. '
          'No single move does it here: the search tried each of '
          'the eight first.',
    ),
    Village(
      name: 'The Charity',
      houseNames: ['the Manor', 'the Mill', 'the Forge', 'the Cot'],
      roads: [(0, 1), (1, 2), (0, 2), (1, 3), (2, 3)],
      spots: [(0.5, 0.12), (0.14, 0.6), (0.86, 0.6), (0.5, 0.9)],
      spread: [-1, -2, 3, 2],
      fewest: 2,
      note: 'Two pounds is this village\'s genus, roads less '
          'houses plus one, and at two pounds clear every one of '
          'its eight classes settles: the census says eight tidy '
          'spreads, and Kirchhoff\'s determinant says eight '
          'spanning trees, neither having heard of the other.',
    ),
    Village(
      name: 'The Long Settlement',
      houseNames: ['the Manor', 'the Mill', 'the Forge', 'the Cot'],
      roads: [(0, 1), (1, 2), (0, 2), (1, 3), (2, 3)],
      spots: [(0.5, 0.12), (0.14, 0.6), (0.86, 0.6), (0.5, 0.9)],
      spread: [-3, -3, 4, 4],
      fewest: 6,
      note: 'Six pounds of debt against eight of coin, and the '
          'settlement still takes six moves: the search walked '
          'every shorter road first and came back empty.',
    ),
    Village(
      name: 'The Short Pound',
      houseNames: ['the Smithy', 'the Tithe Barn', 'the Alehouse'],
      roads: [(0, 1), (1, 2), (0, 2)],
      spots: [(0.5, 0.14), (0.86, 0.72), (0.14, 0.72)],
      spread: [-1, 0, 1],
      fewest: null,
      note: 'The round holds three classes of spread and nought '
          'pounds clear settles exactly one of them; this pound '
          'sits in another, and no lending or borrowing ever '
          'moves a spread out of its class.',
    ),
  ];

  static int get count => all.length;

  static Village at(int number) => all[number];
}
