import 'field.dart';

/// One puzzle: a board with the ends of each thread on it.
class Board {
  const Board({required this.name, required this.rows});

  final String name;

  /// The board as a picture, a letter for each end of a thread and a dot for
  /// an empty cell.
  final List<String> rows;

  Field get field => Field.picture(rows);

  int get side => rows.length;
  int get threads => field.threads;
}

/// The boards, in the order they are met.
///
/// Every one of them has exactly one way of being filled, and that is checked
/// rather than hoped: a test hands each board to the solver and fails if it
/// finds a second answer. Two answers and a guess can be as right as a
/// reason, which is the difference between a puzzle and a way to pass the
/// time.
///
/// They were found backwards. Filling a board is easy — grow threads at
/// random until every cell is taken — and the ends of those threads are a
/// puzzle whose answer is known before it is asked. Whether it is the only
/// answer is what the solver is for, and nearly every board fails that.
class Boards {
  const Boards._();

  static const all = <Board>[
    Board(
      name: 'Five at once',
      rows: ['d.bca', '.....', '...e.', 'dbc..', 'e...a'],
    ),
    Board(
      name: 'Three across',
      rows: ['.....', 'ab.c.', '...b.', '.c...', '....a'],
    ),
    Board(
      name: 'The crossing',
      rows: ['b.d..', '.....', '...ca', '.da..', '.bc..'],
    ),
    Board(
      name: 'Both sides',
      rows: ['b...b', '..c.d', '.ad.a', '.....', '....c'],
    ),
    Board(
      name: 'Up the middle',
      rows: ['..c..', '..a..', '..c.b', 'b..a.', '.....'],
    ),
    Board(
      name: 'Six on six',
      rows: [
        '.b..f.',
        '....e.',
        'beadc.',
        '......',
        '.d...f',
        '.a...c',
      ],
    ),
    Board(
      name: 'The narrows',
      rows: [
        'ca....',
        '....da',
        '..b...',
        '.....b',
        '...c..',
        'e...ed',
      ],
    ),
    Board(
      name: 'Round the edge',
      rows: [
        '......',
        'e...d.',
        '..c..e',
        '.....b',
        '..adc.',
        'ab....',
      ],
    ),
    Board(
      name: 'Four on six',
      rows: [
        '..b..b',
        '......',
        '.....d',
        '..a...',
        '..c..c',
        '...d.a',
      ],
    ),
    Board(
      name: 'Eight',
      rows: [
        '..e.h.g',
        '..f....',
        '.d..e..',
        '..f.dh.',
        '..cb...',
        '.a..a..',
        '.c..b.g',
      ],
    ),
    Board(
      name: 'The moor',
      rows: [
        'd.e....',
        'a...f..',
        '....b.b',
        '.d.....',
        '...a.cf',
        'ce.....',
        '.......',
      ],
    ),
  ];

  static int get count => all.length;

  static Board at(int which) => all[which.clamp(0, all.length - 1)];
}
