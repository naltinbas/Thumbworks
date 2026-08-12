import 'sash.dart';

/// The five sashes that ship.
///
/// Every number here is checked twice before the bake: windows
/// counted down the columns and across the rows over the whole
/// sweep, and tool/check_panes.dart refuses the lot if anything
/// disagrees.
class Sashes {
  static const all = [
    Sash(
      name: 'The Casement',
      across: 3,
      down: 3,
      count: 5,
      ways: 81,
      note: 'Five panes in the little sash leave room to breathe: '
          '81 of the 126 placings frame nothing.',
    ),
    Sash(
      name: 'The Six Panes',
      across: 3,
      down: 3,
      count: 6,
      ways: 6,
      note: 'Six is the little sash\'s limit and it is tight: of '
          '84 placings, six frame no window, every one of them '
          'two panes to a column with no column pair repeated. A '
          'seventh pane is arithmetic away: it would spend five '
          'row-pairs and the sash owns three.',
    ),
    Sash(
      name: 'The Eight',
      across: 4,
      down: 4,
      count: 8,
      ways: 1512,
      note: 'Eight panes sit easily at two a column, spending '
          'four of the six row-pairs with slack to spare: 1,512 '
          'placings land it.',
    ),
    Sash(
      name: 'The Nine',
      across: 4,
      down: 4,
      count: 9,
      ways: 96,
      note: 'Nine is the big sash\'s limit, and the fit is exact: '
          'nine panes spend all six row-pairs with none to spare, '
          'every pair of rows sharing exactly one column. Only 96 '
          'of the 11,440 placings sit so.',
    ),
    Sash(
      name: 'The Tenth Pane',
      across: 4,
      down: 4,
      count: 10,
      ways: 0,
      note: 'Ten panes must spend at least eight row-pairs, '
          'however they split across the columns, and the sash '
          'owns six: the sweep of all 8,008 placings of ten found '
          'a window in every one.',
    ),
  ];

  static int get count => all.length;

  static Sash at(int number) => all[number];
}
