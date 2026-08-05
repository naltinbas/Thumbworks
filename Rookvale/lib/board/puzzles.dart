import 'board.dart';

/// One puzzle: a board, and how many captures it takes to finish.
class Puzzle {
  const Puzzle({
    required this.name,
    required this.rows,
    required this.takes,
  });

  final String name;

  /// The board as a picture, the first line being the far side.
  final List<String> rows;

  /// How many captures finish it, which is one fewer than the pieces on it.
  final int takes;

  Board get board => Board.picture(rows);
}

/// The puzzles, in the order they are met.
///
/// Every one of them has exactly one way through — a test walks the whole
/// tree of every board and fails if there are two. That is the difference
/// between a puzzle and an exercise: with one way through, every capture is
/// forced by something, and there is always a reason to find.
class Puzzles {
  const Puzzles._();

  static const all = <Puzzle>[
    Puzzle(
      name: 'Corner work',
      takes: 3,
      rows: [
        'RB.P',
        'K...',
        '....',
        '....',
      ],
    ),
    Puzzle(
      name: 'Two knights',
      takes: 3,
      rows: [
        '..N.',
        'R...',
        '.NP.',
        '....',
      ],
    ),
    Puzzle(
      name: 'Down the side',
      takes: 4,
      rows: [
        '..KN',
        '..P.',
        '...P',
        '...B',
      ],
    ),
    Puzzle(
      name: 'Two queens',
      takes: 4,
      rows: [
        '.PQ.',
        'Q...',
        '..K.',
        '...R',
      ],
    ),
    Puzzle(
      name: 'The bottom corner',
      takes: 4,
      rows: [
        '....',
        '...R',
        'P.B.',
        '..KB',
      ],
    ),
    Puzzle(
      name: 'Bishops crossing',
      takes: 4,
      rows: [
        'BK..',
        '..B.',
        '.R.N',
        '....',
      ],
    ),
    Puzzle(
      name: 'The long way round',
      takes: 5,
      rows: [
        'N.B.',
        '...N',
        'P...',
        '..BR',
      ],
    ),
    Puzzle(
      name: 'The left wall',
      takes: 5,
      rows: [
        'K...',
        'K...',
        'N...',
        '.NNN',
      ],
    ),
    Puzzle(
      name: 'Four corners',
      takes: 5,
      rows: [
        '.NP.',
        '....',
        '..PB',
        '.NK.',
      ],
    ),
    Puzzle(
      name: 'The queen last',
      takes: 5,
      rows: [
        '.Q.B',
        '.P.R',
        '....',
        'B.K.',
      ],
    ),
  ];

  static int get count => all.length;

  static Puzzle at(int which) => all[which.clamp(0, all.length - 1)];
}
