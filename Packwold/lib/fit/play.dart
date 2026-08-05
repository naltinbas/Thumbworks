import 'dart:typed_data';

import 'boxes.dart';
import 'cover.dart';
import 'pieces.dart';

/// Why a piece cannot go where it was asked to go.
enum Refusal {
  /// Some of it would be off the box altogether.
  overTheEdge,

  /// Some of it would be on a hole.
  onAHole,

  /// Some of it would be on another piece.
  onAnother;

  String get says => switch (this) {
        Refusal.overTheEdge => 'That hangs over the edge.',
        Refusal.onAHole => 'That covers ground the box does not have.',
        Refusal.onAnother => 'Something is already lying there.',
      };
}

/// A box being packed.
///
/// A piece is either in the tray or lying somewhere, and where it lies is a
/// [Placement] — the same thing the solver hands back, so a packing found by
/// the search and a packing made by a finger are the same kind of object and
/// can be compared without translating either.
class Play {
  Play._(this.puzzle, this.box, this._laid, this._owner, this.turned);

  factory Play.of(Puzzle puzzle) {
    final box = puzzle.box;
    return Play._(
      puzzle,
      box,
      List<Placement?>.filled(puzzle.letters.length, null),
      Int32List(box.cells)..fillRange(0, box.cells, -1),
      List<int>.filled(puzzle.letters.length, 0),
    );
  }

  final Puzzle puzzle;
  final Box box;

  final List<Placement?> _laid;

  /// Which piece is on each cell of the box, or -1.
  final Int32List _owner;

  /// Which way up each piece is being held, as a number into its ways of
  /// lying. Kept for pieces in the tray as well as pieces on the box, because
  /// turning a piece round before putting it down is most of the game.
  final List<int> turned;

  List<String> get letters => puzzle.letters;
  int get pieces => letters.length;

  /// Where a piece is lying, or null if it is still in the tray.
  Placement? placed(int piece) => _laid[piece];

  bool isLaid(int piece) => _laid[piece] != null;

  /// Which piece is on a cell of the box, or -1.
  int ownerOf(int cell) => cell < 0 || cell >= box.cells ? -1 : _owner[cell];

  /// Which piece is on a square, or -1 for an empty square or a hole.
  int at(int row, int column) => ownerOf(box.at(row, column));

  int get laid {
    var found = 0;
    for (final one in _laid) {
      if (one != null) found++;
    }
    return found;
  }

  int get filled => laid * 5;
  int get empty => box.cells - filled;

  bool get isDone => laid == pieces;

  /// The way a piece is being held, of the ways it can lie.
  Shape shapeOf(int piece) {
    final ways = Piece.of(letters[piece]).ways;
    return ways[turned[piece] % ways.length];
  }

  int waysFor(int piece) => Piece.of(letters[piece]).ways.length;

  Play _copy() => Play._(
        puzzle,
        box,
        List.of(_laid),
        Int32List.fromList(_owner),
        List.of(turned),
      );

  /// This box with a piece turned a quarter turn to the right.
  ///
  /// A piece already lying somewhere is picked up first. Turning it where it
  /// lies would need somewhere for it to go, and there is no reason to think
  /// there is one.
  Play turn(int piece) => _hold(piece, shapeOf(piece).turned);

  /// This box with a piece flipped over.
  Play flip(int piece) => _hold(piece, shapeOf(piece).flipped);

  /// This box with a piece held a particular way up.
  ///
  /// A shape that turns onto itself finds the way it is already held, so the
  /// button does nothing — which is the truth about that piece rather than a
  /// failure. Turning an X is turning an X.
  Play _hold(int piece, Shape want) {
    final ways = Piece.of(letters[piece]).ways;
    final way = ways.indexWhere((one) => one.picture == want.picture);
    final next = take(piece)._copy();
    if (way >= 0) next.turned[piece] = way;
    return next;
  }

  /// Whether a piece would fit with its first cell on a square, and why not.
  Refusal? whyNot(int piece, int row, int column) {
    final shape = shapeOf(piece);
    final (anchorRow, anchorColumn) = shape.cells.first;

    for (final (r, c) in shape.cells) {
      final onRow = row + r - anchorRow;
      final onColumn = column + c - anchorColumn;
      if (onRow < 0 ||
          onRow >= box.deep ||
          onColumn < 0 ||
          onColumn >= box.wide) {
        return Refusal.overTheEdge;
      }
      final cell = box.at(onRow, onColumn);
      if (cell < 0) return Refusal.onAHole;
      final owner = _owner[cell];
      if (owner >= 0 && owner != piece) return Refusal.onAnother;
    }
    return null;
  }

  bool canLay(int piece, int row, int column) =>
      whyNot(piece, row, column) == null;

  /// This box with a piece put down, its first cell on a square.
  ///
  /// The anchor is the piece's own first cell — the topmost of its leftmost
  /// squares — rather than the corner of the box it would sit in. A shape
  /// like the Y has nothing at the corner of its box, and a piece that lands
  /// a square away from where it was tapped is a piece nobody can aim.
  Play lay(int piece, int row, int column) {
    if (!canLay(piece, row, column)) return this;
    final shape = shapeOf(piece);
    final (anchorRow, anchorColumn) = shape.cells.first;

    final next = take(piece)._copy();
    final cells = <int>[];
    for (final (r, c) in shape.cells) {
      cells.add(box.at(row + r - anchorRow, column + c - anchorColumn));
    }
    for (final cell in cells) {
      next._owner[cell] = piece;
    }
    next._laid[piece] = Placement(
      piece: piece,
      letter: letters[piece],
      shape: shape,
      row: row - anchorRow,
      column: column - anchorColumn,
      cells: cells,
    );
    return next;
  }

  /// This box with a piece turned the way a placement has it and laid where
  /// that placement puts it.
  ///
  /// What the solver hands back is where a piece goes; this is how it gets
  /// there, and it is the only thing that knows how to turn a shape into the
  /// number of a way of holding it.
  Play layAs(Placement want) {
    final ways = Piece.of(letters[want.piece]).ways;
    final way = ways.indexWhere((one) => one.picture == want.shape.picture);
    if (way < 0) return this;

    final next = take(want.piece)._copy();
    next.turned[want.piece] = way;
    final (anchorRow, anchorColumn) = ways[way].cells.first;
    return next.lay(
      want.piece,
      want.row + anchorRow,
      want.column + anchorColumn,
    );
  }

  /// This box with a piece back in the tray.
  Play take(int piece) {
    if (_laid[piece] == null) return this;
    final next = _copy();
    for (final cell in _laid[piece]!.cells) {
      next._owner[cell] = -1;
    }
    next._laid[piece] = null;
    return next;
  }

  Play get again => Play.of(puzzle);

  /// Everything on the box, as the solver would have written it.
  List<Placement> get packing => [
        for (final one in _laid) ?one,
      ];
}
