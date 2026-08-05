import 'pieces.dart';

/// One capture: a piece, and the square it takes on.
class Move {
  const Move(this.from, this.to);

  final int from;
  final int to;

  @override
  bool operator ==(Object other) =>
      other is Move && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$from takes $to';
}

/// A board: a square of squares, some of them with a piece on.
///
/// Immutable, and small enough to be a key: four by four with half a dozen
/// pieces on it is a position a search can put a few hundred thousand of in a
/// set.
///
/// Every move is a capture. That is the whole game — there is nowhere to go
/// that is not somebody else's square — and it is why a position with one
/// piece left is a position that has been solved rather than one that has run
/// out of moves.
class Board {
  Board._(this.side, this.pieces);

  factory Board.of(int side, Map<int, Piece> pieces) =>
      Board._(side, Map.unmodifiable(pieces));

  /// Reads a board out of a picture, one row a line, a letter for a piece and
  /// anything else for an empty square.
  ///
  /// The first line is the top of the board, which is the far side — so a
  /// pawn on the picture moves up the page.
  factory Board.picture(List<String> rows) {
    final side = rows.length;
    final pieces = <int, Piece>{};
    for (var row = 0; row < side; row++) {
      for (var column = 0; column < side; column++) {
        if (column >= rows[row].length) continue;
        final piece = PieceWords.ofLetter(rows[row][column]);
        if (piece != null) pieces[row * side + column] = piece;
      }
    }
    return Board.of(side, pieces);
  }

  final int side;
  final Map<int, Piece> pieces;

  int get squares => side * side;
  int get count => pieces.length;

  int columnOf(int at) => at % side;
  int rowOf(int at) => at ~/ side;

  bool holds(int at) => pieces.containsKey(at);
  Piece? at(int square) => pieces[square];

  /// Whether the board is finished: one piece and nothing for it to take.
  bool get isDone => pieces.length == 1;

  /// Whether the board is lost: more than one piece and no capture left.
  bool get isStuck => pieces.length > 1 && moves.isEmpty;

  /// Every capture there is.
  List<Move> get moves => [
        for (final from in pieces.keys)
          for (final to in _takesFrom(from)) Move(from, to),
      ];

  /// This board after a capture. The taker ends up on the square it took.
  Board after(Move move) {
    if (!_takesFrom(move.from).contains(move.to)) return this;
    final next = Map<int, Piece>.from(pieces)
      ..remove(move.to)
      ..remove(move.from);
    next[move.to] = pieces[move.from]!;
    return Board._(side, Map.unmodifiable(next));
  }

  /// The squares a piece on [from] could take on.
  List<int> _takesFrom(int from) {
    final piece = pieces[from];
    if (piece == null) return const [];

    return switch (piece) {
      // Up the board is forwards, and there is no other direction: a pawn
      // that could take backwards would be a different piece.
      Piece.pawn => [
          for (final step in const [(-1, 1), (1, 1)])
            ?_onePiece(from, step.$1, step.$2),
        ],
      Piece.knight => [
          for (final step in const [
            (1, 2), (2, 1), (2, -1), (1, -2),
            (-1, -2), (-2, -1), (-2, 1), (-1, 2),
          ])
            ?_onePiece(from, step.$1, step.$2),
        ],
      Piece.king => [
          for (final step in const [
            (0, 1), (1, 1), (1, 0), (1, -1),
            (0, -1), (-1, -1), (-1, 0), (-1, 1),
          ])
            ?_onePiece(from, step.$1, step.$2),
        ],
      Piece.bishop => _sliding(from, const [(1, 1), (1, -1), (-1, -1), (-1, 1)]),
      Piece.rook => _sliding(from, const [(0, 1), (1, 0), (0, -1), (-1, 0)]),
      Piece.queen => _sliding(from, const [
          (0, 1), (1, 1), (1, 0), (1, -1),
          (0, -1), (-1, -1), (-1, 0), (-1, 1),
        ]),
    };
  }

  /// The square one step away, if there is a piece on it to take.
  int? _onePiece(int from, int across, int up) {
    final column = columnOf(from) + across;
    final row = rowOf(from) - up;
    if (column < 0 || column >= side || row < 0 || row >= side) return null;
    final square = row * side + column;
    return holds(square) ? square : null;
  }

  /// The first piece along each line, which is the only one that can be
  /// taken: nothing here jumps over anything except a knight.
  List<int> _sliding(int from, List<(int, int)> ways) {
    final found = <int>[];
    for (final (across, up) in ways) {
      var column = columnOf(from) + across;
      var row = rowOf(from) - up;
      while (column >= 0 && column < side && row >= 0 && row < side) {
        final square = row * side + column;
        if (holds(square)) {
          found.add(square);
          break;
        }
        column += across;
        row -= up;
      }
    }
    return found;
  }

  /// What tells two boards apart for a search.
  String get sameness {
    final out = StringBuffer();
    for (var square = 0; square < squares; square++) {
      out.write(pieces[square]?.letter ?? '.');
    }
    return out.toString();
  }

  @override
  String toString() => sameness;
}
