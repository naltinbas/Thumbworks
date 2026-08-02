/// A finished picture: which squares are filled.
///
/// This is the answer to a puzzle, never the thing the player is holding. The
/// player has a [Grid], which is what they have worked out so far; a picture
/// is what they are working out.
class Picture {
  Picture({
    required this.width,
    required this.height,
    required List<bool> filled,
  })  : assert(filled.length == width * height, 'filled must fill the picture'),
        _filled = List.unmodifiable(filled);

  /// A picture from rows of text, where `#` is filled and anything else is
  /// not. Only tests and the odd fixed puzzle use this, but it makes both of
  /// those readable:
  ///
  /// ```dart
  /// Picture.of(['.##.', '####', '.##.']);
  /// ```
  factory Picture.of(List<String> rows) {
    assert(rows.isNotEmpty, 'a picture needs a row');
    final width = rows.first.length;
    assert(
      rows.every((row) => row.length == width),
      'every row must be the same length',
    );
    return Picture(
      width: width,
      height: rows.length,
      filled: [
        for (final row in rows)
          for (final square in row.split('')) square == '#',
      ],
    );
  }

  final int width;
  final int height;
  final List<bool> _filled;

  bool at(int row, int col) => _filled[row * width + col];

  int get area => width * height;
  int get filledCount => _filled.where((square) => square).length;

  List<bool> row(int row) =>
      _filled.sublist(row * width, row * width + width);

  List<bool> column(int col) =>
      [for (var row = 0; row < height; row++) at(row, col)];

  /// The runs of filled squares in a line, which is what a clue is.
  ///
  /// An empty line is `[0]` rather than `[]`, because a clue of nothing still
  /// has to be written down next to the line it belongs to.
  static List<int> runsIn(List<bool> line) {
    final runs = <int>[];
    var run = 0;
    for (final square in line) {
      if (square) {
        run++;
      } else if (run > 0) {
        runs.add(run);
        run = 0;
      }
    }
    if (run > 0) runs.add(run);
    return runs.isEmpty ? const [0] : runs;
  }

  @override
  String toString() => [
        for (var row = 0; row < height; row++)
          [for (var col = 0; col < width; col++) at(row, col) ? '#' : '.']
              .join(),
      ].join('\n');

  @override
  bool operator ==(Object other) =>
      other is Picture &&
      other.width == width &&
      other.height == height &&
      _sameSquares(other._filled);

  bool _sameSquares(List<bool> other) {
    for (var i = 0; i < _filled.length; i++) {
      if (_filled[i] != other[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        width,
        height,
        Object.hashAll(_filled),
      );
}
