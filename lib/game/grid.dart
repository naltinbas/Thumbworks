import 'line.dart';
import 'picture.dart';

/// What has been worked out so far.
///
/// Immutable, so marking a square gives a new grid. That is what makes undo a
/// list rather than a mechanism, and what lets the solver hold a position and
/// compare it with what one more pass produced.
class Grid {
  Grid({
    required this.width,
    required this.height,
    List<Square>? squares,
  })  : assert(
          squares == null || squares.length == width * height,
          'squares must fill the grid',
        ),
        _squares = List.unmodifiable(
          squares ?? List.filled(width * height, Square.unknown),
        );

  /// A grid from rows of text: `#` filled, `.` blank, anything else unknown.
  factory Grid.of(List<String> rows) => Grid(
        width: rows.first.length,
        height: rows.length,
        squares: [
          for (final row in rows)
            for (final square in row.split(''))
              switch (square) {
                '#' => Square.filled,
                '.' => Square.blank,
                _ => Square.unknown,
              },
        ],
      );

  final int width;
  final int height;
  final List<Square> _squares;

  Square at(int row, int col) => _squares[row * width + col];

  List<Square> row(int row) => _squares.sublist(row * width, row * width + width);

  List<Square> column(int col) =>
      [for (var row = 0; row < height; row++) at(row, col)];

  bool get isComplete => !_squares.contains(Square.unknown);

  int get filledCount =>
      _squares.where((square) => square == Square.filled).length;

  /// This grid with one square marked.
  Grid mark(int row, int col, Square to) {
    final squares = List<Square>.from(_squares);
    squares[row * width + col] = to;
    return Grid(width: width, height: height, squares: squares);
  }

  /// This grid with a whole line replaced, which is how the solver writes back
  /// what it worked out.
  Grid withRow(int row, List<Square> line) {
    final squares = List<Square>.from(_squares);
    squares.setRange(row * width, row * width + width, line);
    return Grid(width: width, height: height, squares: squares);
  }

  Grid withColumn(int col, List<Square> line) {
    final squares = List<Square>.from(_squares);
    for (var row = 0; row < height; row++) {
      squares[row * width + col] = line[row];
    }
    return Grid(width: width, height: height, squares: squares);
  }

  /// Whether the filled squares are exactly the picture's.
  ///
  /// Blanks are not compared, because a player who leaves the empty squares
  /// unmarked has still drawn the picture. Marking where the picture is not is
  /// a way of working, not part of the answer.
  bool matches(Picture picture) {
    if (picture.width != width || picture.height != height) return false;
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        if (picture.at(row, col) != (at(row, col) == Square.filled)) {
          return false;
        }
      }
    }
    return true;
  }

  /// The filled squares as a picture, which is what the answer looks like once
  /// there is nothing left unknown.
  Picture get picture => Picture(
        width: width,
        height: height,
        filled: [for (final square in _squares) square == Square.filled],
      );

  @override
  String toString() => [
        for (var row = 0; row < height; row++)
          [
            for (var col = 0; col < width; col++)
              switch (at(row, col)) {
                Square.filled => '#',
                Square.blank => '.',
                Square.unknown => '?',
              },
          ].join(),
      ].join('\n');
}
