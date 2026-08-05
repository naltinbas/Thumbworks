import 'dart:typed_data';

import 'pieces.dart';

/// One piece, lying one way, in one place.
class Placement {
  const Placement({
    required this.piece,
    required this.letter,
    required this.shape,
    required this.row,
    required this.column,
    required this.cells,
  });

  /// Which of the pieces in play this is.
  final int piece;
  final String letter;
  final Shape shape;

  /// Where the shape's top left corner sits in the box.
  final int row;
  final int column;

  /// The cells of the box it covers.
  final List<int> cells;

  /// The squares of the box it covers, as rows and columns.
  List<(int, int)> get squares =>
      [for (final (r, c) in shape.cells) (row + r, column + c)];
}

/// What a search found.
class Packings {
  const Packings({
    required this.count,
    required this.first,
    required this.looked,
  });

  /// How many ways there are of packing the box, stopping wherever the search
  /// was told to.
  final int count;

  /// One of them.
  final List<Placement>? first;

  /// How many times the search picked something to cover, which is Knuth's
  /// way of saying how much work it was.
  final int looked;

  bool get canBeDone => count > 0;
  bool get isOnlyOne => count == 1;
}

/// Packing a box with pieces, as an exact cover problem.
///
/// Every cell of the box has to be covered once and every piece used once.
/// Written down as a matrix — a column for each cell and each piece, a row
/// for each way a piece could lie somewhere — that is exactly the problem
/// Knuth's Algorithm X solves, and the dancing links are what make taking a
/// column out and putting it back cost nothing.
///
/// Choosing the column with the fewest rows left is the whole of the cleverness
/// and it is worth a great deal: it makes the search notice a cell that
/// nothing can cover the moment that becomes true, rather than after another
/// dozen pieces have been laid.
class Cover {
  Cover(this.box, {List<String>? letters})
      : letters = List.unmodifiable(
          letters ?? [for (final piece in Piece.all) piece.letter],
        ) {
    _build();
  }

  final Box box;

  /// The pieces in play, in the order they are asked for.
  final List<String> letters;

  /// Every way any of them could lie anywhere in the box.
  final _ways = <Placement>[];

  /// The links. One node per one in the matrix, plus a header per column and
  /// a root at 0.
  ///
  /// Built as growable lists and then frozen into typed ones, because the
  /// search walks them a million times over and the difference is minutes.
  var _left = <int>[];
  var _right = <int>[];
  var _up = <int>[];
  var _down = <int>[];
  var _column = <int>[];
  var _rowOf = <int>[];
  var _size = <int>[];

  int get _columns => letters.length + box.cells;

  List<Placement> get ways => List.unmodifiable(_ways);

  int _node(int left, int right, int up, int down, int column, int row) {
    _left.add(left);
    _right.add(right);
    _up.add(up);
    _down.add(down);
    _column.add(column);
    _rowOf.add(row);
    return _left.length - 1;
  }

  void _build() {
    // The root, then a header for each column: one per piece, then one per
    // cell of the box.
    _node(0, 0, 0, 0, 0, -1);
    for (var i = 1; i <= _columns; i++) {
      final here = _node(i - 1, 0, i, i, i, -1);
      _right[i - 1] = here;
      _left[0] = here;
      _size.add(0);
    }
    _right[_columns] = 0;

    for (var piece = 0; piece < letters.length; piece++) {
      for (final shape in Piece.of(letters[piece]).ways) {
        for (var row = 0; row + shape.deep <= box.deep; row++) {
          for (var column = 0; column + shape.wide <= box.wide; column++) {
            final cells = <int>[];
            for (final (r, c) in shape.cells) {
              final at = box.at(row + r, column + c);
              if (at < 0) break;
              cells.add(at);
            }
            if (cells.length != shape.cells.length) continue;
            _lay(Placement(
              piece: piece,
              letter: letters[piece],
              shape: shape,
              row: row,
              column: column,
              cells: cells,
            ));
          }
        }
      }
    }

    _left = Int32List.fromList(_left);
    _right = Int32List.fromList(_right);
    _up = Int32List.fromList(_up);
    _down = Int32List.fromList(_down);
    _column = Int32List.fromList(_column);
    _rowOf = Int32List.fromList(_rowOf);
    _size = Int32List.fromList(_size);
  }

  /// Puts one way of lying into the matrix as a row.
  void _lay(Placement way) {
    final which = _ways.length;
    _ways.add(way);

    var first = -1;
    var last = -1;
    for (final column in [
      1 + way.piece,
      for (final cell in way.cells) 1 + letters.length + cell,
    ]) {
      final here = _node(last, -1, _up[column], column, column, which);
      _down[_up[column]] = here;
      _up[column] = here;
      _size[column - 1]++;

      if (first < 0) {
        first = here;
        _left[here] = here;
        _right[here] = here;
      } else {
        _right[last] = here;
        _left[first] = here;
        _right[here] = first;
      }
      last = here;
    }
  }

  void _cover(int column) {
    _right[_left[column]] = _right[column];
    _left[_right[column]] = _left[column];
    for (var row = _down[column]; row != column; row = _down[row]) {
      for (var node = _right[row]; node != row; node = _right[node]) {
        _down[_up[node]] = _down[node];
        _up[_down[node]] = _up[node];
        _size[_column[node] - 1]--;
      }
    }
  }

  void _uncover(int column) {
    for (var row = _up[column]; row != column; row = _up[row]) {
      for (var node = _left[row]; node != row; node = _left[node]) {
        _size[_column[node] - 1]++;
        _down[_up[node]] = node;
        _up[_down[node]] = node;
      }
    }
    _right[_left[column]] = column;
    _left[_right[column]] = column;
  }

  /// Counts the ways of packing the box, stopping once [enough] are found.
  ///
  /// Two is enough for a puzzle. Everything is enough for a count, and that
  /// is what the famous numbers are.
  Packings solve({int enough = 2, int give = 1 << 30}) {
    if (box.cells != letters.length * 5) {
      return const Packings(count: 0, first: null, looked: 0);
    }

    var count = 0;
    var looked = 0;
    List<Placement>? first;
    final laid = <int>[];

    void walk() {
      if (count >= enough || looked > give) return;

      if (_right[0] == 0) {
        count++;
        first ??= [for (final row in laid) _ways[row]];
        return;
      }

      // The column with the fewest rows left. A column with none is a cell
      // nothing can cover or a piece with nowhere to go, and the search turns
      // round at once.
      var chosen = 0;
      var fewest = 1 << 30;
      for (var column = _right[0]; column != 0; column = _right[column]) {
        if (_size[column - 1] < fewest) {
          fewest = _size[column - 1];
          chosen = column;
        }
      }
      if (fewest == 0) return;

      looked++;
      _cover(chosen);
      for (var row = _down[chosen]; row != chosen; row = _down[row]) {
        laid.add(_rowOf[row]);
        for (var node = _right[row]; node != row; node = _right[node]) {
          _cover(_column[node]);
        }

        walk();

        for (var node = _left[row]; node != row; node = _left[node]) {
          _uncover(_column[node]);
        }
        laid.removeLast();
        if (count >= enough) break;
      }
      _uncover(chosen);
    }

    walk();
    return Packings(count: count, first: first, looked: looked);
  }
}
