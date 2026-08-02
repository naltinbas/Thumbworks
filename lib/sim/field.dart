import 'dart:math';

/// A square on the field.
class Cell {
  const Cell(this.col, this.row);

  final int col;
  final int row;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.col == col && other.row == row;

  @override
  int get hashCode => col * 31 + row;

  @override
  String toString() => '($col,$row)';
}

/// A point on the field, in cells rather than pixels.
///
/// The simulation never knows how big a cell is on a screen. That is the
/// view's business, and keeping it out of here is what lets the same run be
/// replayed on any phone and stepped through in a test.
class Spot {
  const Spot(this.x, this.y);

  final double x;
  final double y;

  Spot operator +(Spot o) => Spot(x + o.x, y + o.y);
  Spot operator -(Spot o) => Spot(x - o.x, y - o.y);
  Spot operator *(double k) => Spot(x * k, y * k);

  double get length => sqrt(x * x + y * y);

  @override
  String toString() => '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';
}

/// The map: where the walkers walk, and where they cannot.
///
/// One field, laid out by hand rather than generated. A defence game lives on
/// the shape of its path — where it doubles back, where two stretches run
/// close enough that one tower covers both — and a random path is a path with
/// no such places in it.
class Field {
  const Field._(this.path);

  /// The route, cell by cell, from where the walkers come in to where they get
  /// out. They walk between the middles of consecutive cells.
  final List<Cell> path;

  static const columns = 9;
  static const rows = 13;

  /// The one map. It comes in at the top, crosses three times and leaves at
  /// the bottom, which gives four straight runs a tower can be put beside and
  /// two turns where a slowing tower is worth more than a shooting one.
  static final Field only = Field._(_walk(const [
    Cell(4, 0),
    Cell(4, 2),
    Cell(1, 2),
    Cell(1, 5),
    Cell(7, 5),
    Cell(7, 8),
    Cell(2, 8),
    Cell(2, 11),
    Cell(6, 11),
    Cell(6, 12),
  ]));

  /// Fills in the cells between the corners, so the path is every cell walked
  /// through rather than the handful that were typed.
  static List<Cell> _walk(List<Cell> corners) {
    final cells = <Cell>[corners.first];
    for (var i = 1; i < corners.length; i++) {
      final from = corners[i - 1];
      final to = corners[i];
      assert(
        from.col == to.col || from.row == to.row,
        'the path turns square corners: $from to $to',
      );
      final stepCol = (to.col - from.col).sign;
      final stepRow = (to.row - from.row).sign;
      var at = from;
      while (at != to) {
        at = Cell(at.col + stepCol, at.row + stepRow);
        cells.add(at);
      }
    }
    return List.unmodifiable(cells);
  }

  Cell get entrance => path.first;
  Cell get exit => path.last;

  /// How far along the path is, in cells.
  int get length => path.length - 1;

  bool onPath(Cell cell) => path.contains(cell);

  bool inside(Cell cell) =>
      cell.col >= 0 && cell.col < columns && cell.row >= 0 && cell.row < rows;

  /// Whether a tower may be put here.
  bool canBuildOn(Cell cell) => inside(cell) && !onPath(cell);

  /// Where something is when it has walked [along] cells of the path.
  ///
  /// Between two cells it is on the line between their middles, which is what
  /// makes a walker slide rather than hop.
  Spot at(double along) {
    if (along <= 0) return _middleOf(path.first);
    if (along >= length) return _middleOf(path.last);
    final step = along.floor();
    final part = along - step;
    final from = _middleOf(path[step]);
    final to = _middleOf(path[step + 1]);
    return from + (to - from) * part;
  }

  static Spot _middleOf(Cell cell) => Spot(cell.col + 0.5, cell.row + 0.5);
}
