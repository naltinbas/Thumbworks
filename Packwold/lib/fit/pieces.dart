import 'dart:typed_data';

/// The twelve pentominoes, by their usual letters.
///
/// Each one is written down once, as the cells of one orientation, and the
/// rest are worked out. Turning and flipping a shape by hand twelve times
/// over is how a game ends up shipping a piece with a cell missing.
class Piece {
  const Piece._(this.letter, this.cells);

  final String letter;

  /// The cells of the shape it was written down as, each a row and a column.
  final List<(int, int)> cells;

  static const all = <Piece>[
    // F  .##
    //    ##.
    //    .#.
    Piece._('F', [(0, 1), (0, 2), (1, 0), (1, 1), (2, 1)]),
    // I  #####
    Piece._('I', [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)]),
    // L  #.
    //    #.
    //    #.
    //    ##
    Piece._('L', [(0, 0), (1, 0), (2, 0), (3, 0), (3, 1)]),
    // N  .#
    //    .#
    //    ##
    //    #.
    Piece._('N', [(0, 1), (1, 1), (2, 0), (2, 1), (3, 0)]),
    // P  ##
    //    ##
    //    #.
    Piece._('P', [(0, 0), (0, 1), (1, 0), (1, 1), (2, 0)]),
    // T  ###
    //    .#.
    //    .#.
    Piece._('T', [(0, 0), (0, 1), (0, 2), (1, 1), (2, 1)]),
    // U  #.#
    //    ###
    Piece._('U', [(0, 0), (0, 2), (1, 0), (1, 1), (1, 2)]),
    // V  #..
    //    #..
    //    ###
    Piece._('V', [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)]),
    // W  #..
    //    ##.
    //    .##
    Piece._('W', [(0, 0), (1, 0), (1, 1), (2, 1), (2, 2)]),
    // X  .#.
    //    ###
    //    .#.
    Piece._('X', [(0, 1), (1, 0), (1, 1), (1, 2), (2, 1)]),
    // Y  .#
    //    ##
    //    .#
    //    .#
    Piece._('Y', [(0, 1), (1, 0), (1, 1), (2, 1), (3, 1)]),
    // Z  ##.
    //    .#.
    //    .##
    Piece._('Z', [(0, 0), (0, 1), (1, 1), (2, 1), (2, 2)]),
  ];

  static int get count => all.length;

  static Piece of(String letter) =>
      all.firstWhere((piece) => piece.letter == letter);

  static int numberOf(String letter) =>
      all.indexWhere((piece) => piece.letter == letter);

  /// Every way the piece can lie: turned four ways and flipped, with the
  /// repeats thrown out. A cross has one, a straight line two, most have
  /// eight.
  List<Shape> get ways {
    final found = <String, Shape>{};
    var lying = cells;
    for (var flip = 0; flip < 2; flip++) {
      for (var turn = 0; turn < 4; turn++) {
        final shape = Shape(letter, lying);
        found[shape.picture] = shape;
        lying = [for (final (row, column) in lying) (column, -row)];
      }
      lying = [for (final (row, column) in lying) (row, -column)];
    }
    return found.values.toList();
  }
}

/// One way a piece can lie, pulled up against the top left corner.
class Shape {
  Shape(this.letter, List<(int, int)> cells) {
    var leastRow = cells.first.$1;
    var leastColumn = cells.first.$2;
    for (final (row, column) in cells) {
      if (row < leastRow) leastRow = row;
      if (column < leastColumn) leastColumn = column;
    }
    final pulled = [
      for (final (row, column) in cells) (row - leastRow, column - leastColumn),
    ]..sort((a, b) => a.$1 == b.$1 ? a.$2 - b.$2 : a.$1 - b.$1);

    this.cells = List.unmodifiable(pulled);
    var deep = 0;
    var wide = 0;
    for (final (row, column) in pulled) {
      if (row + 1 > deep) deep = row + 1;
      if (column + 1 > wide) wide = column + 1;
    }
    this.deep = deep;
    this.wide = wide;
  }

  final String letter;
  late final List<(int, int)> cells;
  late final int deep;
  late final int wide;

  /// The same shape turned a quarter turn to the right.
  Shape get turned => Shape(letter, [for (final (r, c) in cells) (c, -r)]);

  /// The same shape mirrored left to right.
  Shape get flipped => Shape(letter, [for (final (r, c) in cells) (r, -c)]);

  /// The shape as a block of hashes and dots, which is what tells two ways of
  /// lying apart.
  String get picture {
    final rows = <String>[];
    for (var row = 0; row < deep; row++) {
      final line = StringBuffer();
      for (var column = 0; column < wide; column++) {
        line.write(cells.contains((row, column)) ? '#' : '.');
      }
      rows.add('$line');
    }
    return rows.join('/');
  }

  @override
  String toString() => '$letter ${picture.replaceAll('/', '|')}';
}

/// A box to fill, as a picture: a dot for a cell to fill and a hash for a
/// hole that is not part of it.
class Box {
  Box(List<String> rows)
      : rows = List.unmodifiable(rows),
        wide = rows.first.length,
        deep = rows.length {
    final where = Int32List(wide * deep)..fillRange(0, wide * deep, -1);
    var cells = 0;
    for (var row = 0; row < deep; row++) {
      for (var column = 0; column < wide; column++) {
        if (rows[row][column] == '#') continue;
        where[row * wide + column] = cells++;
      }
    }
    _where = where;
    this.cells = cells;
  }

  /// A plain rectangle.
  factory Box.plain(int wide, int deep) =>
      Box([for (var row = 0; row < deep; row++) '.' * wide]);

  final List<String> rows;
  final int wide;
  final int deep;

  /// How many cells there are to fill.
  late final int cells;

  late final Int32List _where;

  /// Which of the cells to fill this square is, or -1 for a hole.
  int at(int row, int column) {
    if (row < 0 || row >= deep || column < 0 || column >= wide) return -1;
    return _where[row * wide + column];
  }

  bool isHole(int row, int column) => at(row, column) < 0;
}
