import 'tray.dart';

/// The trays that ship.
///
/// Every number here is checked twice over: tool/check_trays.dart walks
/// each one out and refuses the bake if a written figure is wrong, and
/// the suite sweeps the parities besides.
class Trays {
  static const all = [
    Tray(
      name: 'The Little Tray',
      rows: 2,
      cols: 3,
      tiles: [2, 3, 5, 1, 4, 0],
      fewest: 6,
    ),
    Tray(
      name: 'The Morning Shunt',
      rows: 3,
      cols: 3,
      tiles: [1, 2, 3, 6, 7, 8, 4, 5, 0],
      fewest: 10,
    ),
    Tray(
      name: 'The Round of Eight',
      rows: 3,
      cols: 3,
      tiles: [1, 2, 3, 7, 8, 6, 4, 5, 0],
      fewest: 18,
    ),
    Tray(
      name: 'The Far Corner',
      rows: 2,
      cols: 3,
      tiles: [4, 5, 0, 1, 2, 3],
      fewest: 21,
      note: 'No board of the little tray lies farther from home than '
          'this one: the walk of all three hundred and sixty says '
          'twenty one, and nothing says more.',
    ),
    Tray(
      name: 'The Long Way Round',
      rows: 3,
      cols: 3,
      tiles: [6, 4, 7, 8, 5, 0, 3, 2, 1],
      fewest: 31,
      note: 'Of all 181,440 boards there are, exactly two lie thirty '
          'one shunts from home and none lies farther. This is one of '
          'the two.',
    ),
    Tray(
      name: 'The Old Swindle',
      rows: 3,
      cols: 3,
      tiles: [1, 2, 3, 4, 5, 6, 8, 7, 0],
      fewest: null,
      note: 'Sam Loyd offered a thousand dollars to anyone who could '
          'swap the last two tiles back. The count above is why the '
          'money was safe.',
    ),
  ];

  static int get count => all.length;

  static Tray at(int number) => all[number];
}
