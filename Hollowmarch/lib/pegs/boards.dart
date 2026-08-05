import 'field.dart';

/// One puzzle: a shape of board, and the hollow that starts empty.
class Board {
  const Board({
    required this.name,
    required this.rows,
    required this.empty,
    this.par,
  });

  final String name;

  /// The shape as a picture: a dot for a hollow, a hash for a square that is
  /// not part of the board.
  final List<String> rows;

  /// The hollow with no peg in it at the start, as a row and a column.
  final (int, int) empty;

  /// The fewest moves this board can be finished in, where a move is one peg
  /// jumping once or several times running.
  ///
  /// Null on the board where it is not known — the big one, where the number
  /// of positions is past what anything here could walk. A number that is
  /// there is a proved number: a test works it out again from nothing and
  /// fails if it comes out different.
  final int? par;

  Field get field => Field(rows);

  int get hollows => field.hollows;

  /// The pegs at the start: every hollow but one.
  int get start {
    final field = this.field;
    return field.full & ~(1 << field.at(empty.$1, empty.$2));
  }
}

/// The boards, in the order they are met.
///
/// The last one is the board this game has been played on since somebody at
/// the court of Louis XIV was bored, and it is here for one reason: the rule
/// of three has something to say about it that no amount of playing would
/// tell you.
class Boards {
  const Boards._();

  static const all = <Board>[
    Board(
      name: 'Twelve hollows',
      rows: ['....', '....', '....'],
      empty: (0, 0),
      par: 6,
    ),
    Board(
      name: 'The ell',
      rows: ['..##', '..##', '....', '....'],
      empty: (1, 0),
      par: 8,
    ),
    Board(
      name: 'The steps',
      rows: ['..##', '...#', '....', '....'],
      empty: (1, 0),
      par: 8,
    ),
    Board(
      name: 'The long fifteen',
      rows: ['.....', '.....', '.....'],
      empty: (0, 2),
      par: 8,
    ),
    Board(
      name: 'Sixteen square',
      rows: ['....', '....', '....', '....'],
      empty: (0, 1),
      par: 9,
    ),
    Board(
      name: 'The arrow',
      rows: ['##.##', '#...#', '.....', '#...#', '#...#'],
      empty: (2, 2),
      par: 10,
    ),
    Board(
      name: 'The small cross',
      rows: ['#...#', '#...#', '.....', '#...#', '#...#'],
      empty: (2, 1),
      par: 9,
    ),
    Board(
      name: 'Across the middle',
      rows: ['#...#', '#...#', '.....', '#...#', '#...#'],
      empty: (0, 2),
      par: 11,
    ),
    Board(
      name: 'The cross',
      rows: ['##...##', '##...##', '.......', '##...##', '##...##'],
      empty: (2, 2),
      par: 11,
    ),
    Board(
      name: 'The wide cross',
      rows: ['#.....#', '.......', '.......', '#.....#'],
      empty: (3, 4),
      par: 12,
    ),
    Board(
      name: 'The central game',
      rows: [
        '##...##',
        '##...##',
        '.......',
        '.......',
        '.......',
        '##...##',
        '##...##',
      ],
      empty: (3, 3),
    ),
  ];

  static int get count => all.length;

  static Board at(int which) => all[which.clamp(0, all.length - 1)];
}
