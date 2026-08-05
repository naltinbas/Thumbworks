import 'pieces.dart';

/// One puzzle: a box, and the pieces that go in it.
class Puzzle {
  const Puzzle({
    required this.name,
    required this.rows,
    required this.letters,
  });

  final String name;

  /// The box as a picture: a dot for ground to cover, a hash for a hole.
  final List<String> rows;

  /// The pieces in the tray, by letter.
  final List<String> letters;

  Box get box => Box(rows);

  int get pieces => letters.length;
  int get wide => rows.first.length;
  int get deep => rows.length;
}

/// The puzzles, in the order they are met.
///
/// Every one of them has exactly one packing, and that is checked rather than
/// hoped: a test hands each box to the solver and fails if it finds a second.
/// Two packings and there is nothing to work out, because a guess can be as
/// right as a reason.
///
/// They were found backwards. Scattering a few pentominoes is easy, and the
/// ground they cover is a box that can certainly be packed. Whether that is
/// the only way is what the solver is for, and most boxes fail it — a box of
/// five pieces usually has half a dozen packings.
class Puzzles {
  const Puzzles._();

  static const all = <Puzzle>[
    Puzzle(
      name: 'Smallholding',
      rows: ['#...#', '#.#..', '.....', '#....', '.....'],
      letters: ['L', 'P', 'Y', 'Z'],
    ),
    Puzzle(
      name: 'The clearing',
      rows: ['#.#.#', '.....', '.....', '#..#.', '.....'],
      letters: ['I', 'T', 'U', 'W'],
    ),
    Puzzle(
      name: 'Four ways',
      rows: ['#....', '#...#', '.....', '.#...', '#....'],
      letters: ['P', 'W', 'Y', 'Z'],
    ),
    Puzzle(
      name: 'Five acres',
      rows: ['.##..#', '.....#', '......', '......', '.#....'],
      letters: ['I', 'V', 'X', 'Y', 'Z'],
    ),
    Puzzle(
      name: 'The long field',
      rows: ['..##..', '......', '......', '......', '.#..##'],
      letters: ['F', 'I', 'P', 'U', 'W'],
    ),
    Puzzle(
      name: 'Half the set',
      rows: ['....##', '#....#', '......', '....#.', '......', '#.....'],
      letters: ['I', 'P', 'T', 'V', 'W', 'Y'],
    ),
    Puzzle(
      name: 'The stile',
      rows: ['......', '..#...', '..#...', '......', '..#...', '#...##'],
      letters: ['F', 'L', 'N', 'W', 'Y', 'Z'],
    ),
    Puzzle(
      name: 'Seven at the gate',
      rows: [
        '#......',
        '...#.#.',
        '#......',
        '.......',
        '#......',
        '....##.',
      ],
      letters: ['F', 'L', 'T', 'U', 'V', 'W', 'Y'],
    ),
    Puzzle(
      name: 'Eight acres',
      rows: [
        '#.....#',
        '..#....',
        '.....#.',
        '...#...',
        '...#...',
        '.##....',
        '...#...',
      ],
      letters: ['I', 'L', 'P', 'T', 'U', 'V', 'W', 'Z'],
    ),
    Puzzle(
      name: 'The nine',
      rows: [
        '....#...',
        '......#.',
        '#...#...',
        '........',
        '.....##.',
        '.#......',
        '.#.#..##',
      ],
      letters: ['F', 'I', 'L', 'N', 'U', 'V', 'W', 'Y', 'Z'],
    ),
    Puzzle(
      name: 'Ten of twelve',
      rows: [
        '.#......',
        '........',
        '...#.##.',
        '.....#..',
        '#.#.....',
        '##..#...',
        '....##..',
        '.#.....#',
      ],
      letters: ['I', 'L', 'N', 'P', 'T', 'U', 'W', 'X', 'Y', 'Z'],
    ),
  ];

  static int get count => all.length;

  static Puzzle at(int which) => all[which.clamp(0, all.length - 1)];
}
