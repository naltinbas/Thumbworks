import 'grid.dart';

/// One board: the lamps that start lit, and the fewest presses that put them
/// out.
class Level {
  const Level({
    required this.name,
    required this.across,
    required this.rows,
    required this.presses,
  });

  final String name;
  final int across;

  /// The board as a picture, `O` for a lamp that is lit.
  final List<String> rows;

  /// The fewest presses that turn every lamp off.
  ///
  /// Not a good score somebody got and not the length of a solution somebody
  /// found. Pressing lamps is a set of linear equations, and this is the
  /// smallest answer it has — a test solves every board and fails if the
  /// number here is not it.
  final int presses;

  int get down => rows.length;

  Grid get grid => Grid(across, down);

  /// The lamps that are lit, as one number.
  int get lit {
    var board = 0;
    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < across; column++) {
        if (rows[row][column] == 'O') board |= 1 << (row * across + column);
      }
    }
    return board;
  }

  int get lamps => across * down;
}

/// The boards, in the order they are met.
///
/// Every one of them can be turned off, which is not a given: on a five by
/// five only one board in four can, and on a four by four only one in
/// sixteen. A board that cannot be turned off is a board nobody can finish,
/// so the tool that finds these throws away everything that is not solvable
/// before it looks at anything else.
class Levels {
  const Levels._();

  static const all = <Level>[
    Level(
      name: 'First light',
      across: 3,
      presses: 3,
      rows: ['OOO', 'OOO', 'O.O'],
    ),
    Level(
      name: 'Three by three',
      across: 3,
      presses: 5,
      rows: ['..O', '.O.', '.OO'],
    ),
    Level(
      name: 'The four',
      across: 4,
      presses: 3,
      rows: ['O.OO', '.OOO', '.O..', '....'],
    ),
    Level(
      name: 'The corner room',
      across: 4,
      presses: 5,
      rows: ['.OO.', 'O.OO', 'OO.O', '....'],
    ),
    Level(
      name: 'Sixteen',
      across: 4,
      presses: 7,
      rows: ['OO.O', 'OO.O', '..OO', 'OOO.'],
    ),
    Level(
      name: 'The short wall',
      across: 5,
      presses: 7,
      rows: ['.OO..', '.O.OO', 'O..OO', 'OOO.O'],
    ),
    Level(
      name: 'Five by five',
      across: 5,
      presses: 6,
      rows: ['...OO', '.OO.O', 'O..OO', 'OO.OO', 'O.OOO'],
    ),
    Level(
      name: 'The middle',
      across: 5,
      presses: 9,
      rows: ['OOOO.', '....O', '.O..O', 'OOOOO', 'OO..O'],
    ),
    Level(
      name: 'Nearly all of them',
      across: 5,
      presses: 12,
      rows: ['...O.', '.O..O', '.O..O', 'OO...', 'OOOO.'],
    ),
    Level(
      name: 'The whole hill',
      across: 6,
      presses: 18,
      rows: [
        '.OOO..',
        'OO.OOO',
        'O.O...',
        'O....O',
        '...OO.',
        '.O...O',
      ],
    ),
  ];

  static int get count => all.length;

  static Level at(int which) => all[which.clamp(0, all.length - 1)];
}
