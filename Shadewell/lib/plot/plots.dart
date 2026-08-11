import 'plot.dart';

/// The plots that ship.
///
/// Every number here is checked twice over: tool/check_plots.dart
/// stacks every filling and runs the line-solver, and refuses the bake
/// on any disagreement.
class Plots {
  static const all = [
    Plot(
      name: 'The Tree',
      wide: 5,
      high: 5,
      rowTallies: [
        [1],
        [3],
        [5],
        [1],
        [1],
      ],
      colTallies: [
        [1],
        [2],
        [5],
        [2],
        [1],
      ],
      solutions: 1,
      picture: [0x04, 0x0E, 0x1F, 0x04, 0x04],
      note: 'One picture fits, and reason alone finds it: the middle '
          'column fills first, and the rest follows line by line.',
    ),
    Plot(
      name: 'The Boat',
      wide: 5,
      high: 5,
      rowTallies: [
        [1],
        [2],
        [5],
        [3],
        [1],
      ],
      colTallies: [
        [1],
        [2],
        [5],
        [3],
        [1],
      ],
      solutions: 1,
      picture: [0x04, 0x0C, 0x1F, 0x0E, 0x04],
      note: 'The hull and the sail hold each other up: every deduction '
          'the line-solver makes, you can make at the same tallies.',
    ),
    Plot(
      name: 'The Anchor',
      wide: 5,
      high: 5,
      rowTallies: [
        [1],
        [1, 1],
        [1],
        [1, 1, 1],
        [3],
      ],
      colTallies: [
        [1],
        [1, 1],
        [1, 3],
        [1, 1],
        [1],
      ],
      solutions: 1,
      picture: [0x04, 0x0A, 0x04, 0x15, 0x0E],
      note: 'Ones nearly everywhere, and still only one picture: the '
          'stacking tried every filling of the rows to be sure.',
    ),
    Plot(
      name: 'The Well',
      wide: 5,
      high: 5,
      rowTallies: [
        [5],
        [1, 1],
        [1, 1, 1],
        [1, 1],
        [5],
      ],
      colTallies: [
        [5],
        [1, 1],
        [1, 1, 1],
        [1, 1],
        [5],
      ],
      solutions: 1,
      picture: [0x1F, 0x11, 0x15, 0x11, 0x1F],
      note: 'The wall, the shaft, and the stone in the water. The '
          'same tallies read down as across, and one picture keeps '
          'them all.',
    ),
    Plot(
      name: 'The Two Gardens',
      wide: 5,
      high: 5,
      rowTallies: [
        [2],
        [2],
        [0],
        [2],
        [2],
      ],
      colTallies: [
        [2],
        [2],
        [0],
        [2],
        [2],
      ],
      solutions: 2,
      note: 'These tallies keep a secret badly: two pictures fit '
          'them, each the other turned head over heels. Shade either '
          'and the tallies are satisfied; they never named one '
          'garden. Ask why twice to see both.',
    ),
    Plot(
      name: 'The Short Tally',
      wide: 5,
      high: 5,
      rowTallies: [
        [2],
        [1],
        [3],
        [1],
        [2],
      ],
      colTallies: [
        [1],
        [2],
        [2],
        [2],
        [1],
      ],
      solutions: 0,
      note: 'Count before you shade: the rows ask for nine shaded '
          'cells and the columns for eight, and one grid cannot hold '
          'both. The stacking tried every filling all the same and '
          'found none.',
    ),
  ];

  static int get count => all.length;

  static Plot at(int number) => all[number];
}
