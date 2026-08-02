/// What is standing on a square.
enum Piece {
  /// The besiegers. They start on the edges and win by taking the king.
  raider,

  /// The king's men. They start around him and win by getting him out.
  guard,

  /// The one piece that matters.
  king,
}

/// Whose turn it is, and which side a piece belongs to.
enum Side {
  raiders,
  guards;

  Side get other => this == raiders ? guards : raiders;

  bool owns(Piece piece) => switch (piece) {
        Piece.raider => this == raiders,
        Piece.guard || Piece.king => this == guards,
      };
}

/// A square, by row and column from the top left.
class Square {
  const Square(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is Square && other.row == row && other.col == col;

  @override
  int get hashCode => row * 31 + col;

  @override
  String toString() => '(${row + 1},${String.fromCharCode(97 + col)})';
}

/// A move: a piece and where it is going.
class Move {
  const Move(this.from, this.to);

  final Square from;
  final Square to;

  @override
  bool operator ==(Object other) =>
      other is Move && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$from-$to';
}

/// How a game ended.
enum Outcome {
  /// Still going.
  none,

  /// The king reached a corner.
  kingAway,

  /// The king was taken.
  kingTaken,

  /// The side to move has nowhere to go. They lose: a side that cannot move
  /// has been shut in, and calling that a draw would reward the shutting-in
  /// side with half a point for a total victory.
  shutIn,
}

/// A position: what is where, and whose move it is.
///
/// Immutable. Playing a move gives a new board, which is what lets the search
/// hold a position and compare it against what a move produced, and what makes
/// undo a list rather than a mechanism.
///
/// The board is seven squares across. The king starts in the middle on the
/// throne with four guards around him; eight raiders sit in groups of two at
/// the middle of each edge. Guards win by walking the king to any corner,
/// raiders by surrounding him.
class Board {
  Board._({
    required List<Piece?> squares,
    required this.turn,
    required this.outcome,
  }) : _squares = List.unmodifiable(squares);

  /// The opening position: a cross of raiders around a diamond of guards.
  ///
  /// Eight raiders, two to an edge. Twelve was tried first, on the grounds
  /// that a siege ought to look like a siege, and it is not a game: at every
  /// search depth the raiders won four games in five. Eight is the count the
  /// board is actually balanced at.
  ///
  /// Raiders move first, which is the usual arrangement — they have the men
  /// and the guards have the plan.
  factory Board.opening() {
    final squares = List<Piece?>.filled(size * size, null);
    void put(int row, int col, Piece piece) => squares[row * size + col] = piece;

    for (final at in _raiders) {
      put(at[0], at[1], Piece.raider);
    }

    for (final at in const [[2, 3], [3, 2], [3, 4], [4, 3]]) {
      put(at[0], at[1], Piece.guard);
    }
    put(3, 3, Piece.king);

    return Board._(squares: squares, turn: Side.raiders, outcome: Outcome.none);
  }

  /// A position from rows of text, for tests and for the opening this game
  /// happens to use. `R` raider, `G` guard, `K` king, anything else empty.
  factory Board.of(List<String> rows, {Side turn = Side.raiders}) {
    assert(rows.length == size, 'a board is $size rows');
    final squares = <Piece?>[];
    for (final row in rows) {
      assert(row.length == size, 'a row is $size squares');
      for (final square in row.split('')) {
        squares.add(switch (square) {
          'R' => Piece.raider,
          'G' => Piece.guard,
          'K' => Piece.king,
          _ => null,
        });
      }
    }
    return Board._(squares: squares, turn: turn, outcome: Outcome.none);
  }

  /// Where the raiders start. Set at the top so the balancing runs in
  /// tool/balance.dart can try another arrangement without picking through
  /// the constructor.
  static const _raiders = [
    [0, 2], [0, 3], [0, 4],
    [2, 0], [3, 0], [4, 0],
    [2, 6], [3, 6], [4, 6],
    [6, 2], [6, 3], [6, 4],
  ];

  static const size = 7;

  /// The squares only the king may stand on: the four corners and the throne
  /// he starts on. They also help take a piece standing beside them, which is
  /// what stops the middle of the board being a safe place to park.
  static const throne = Square(3, 3);
  static const corners = [
    Square(0, 0),
    Square(0, size - 1),
    Square(size - 1, 0),
    Square(size - 1, size - 1),
  ];

  final List<Piece?> _squares;
  final Side turn;
  final Outcome outcome;

  bool get isOver => outcome != Outcome.none;

  Piece? at(Square square) => _squares[square.row * size + square.col];

  bool inside(Square square) =>
      square.row >= 0 &&
      square.row < size &&
      square.col >= 0 &&
      square.col < size;

  static bool isCorner(Square square) => corners.contains(square);

  /// Whether only the king may stand here.
  static bool isRestricted(Square square) =>
      isCorner(square) || square == throne;

  Square? get kingAt {
    for (var i = 0; i < _squares.length; i++) {
      if (_squares[i] == Piece.king) return Square(i ~/ size, i % size);
    }
    return null;
  }

  Iterable<Square> get occupied sync* {
    for (var i = 0; i < _squares.length; i++) {
      if (_squares[i] != null) yield Square(i ~/ size, i % size);
    }
  }

  int count(Piece piece) => _squares.where((p) => p == piece).length;

  /// Every move the side to move may play.
  ///
  /// Pieces move like a rook: any distance along a row or column, over nothing.
  /// Only the king may finish on a corner or the throne.
  List<Move> get moves {
    if (isOver) return const [];
    final moves = <Move>[];
    for (final from in occupied) {
      final piece = at(from)!;
      if (!turn.owns(piece)) continue;
      for (final step in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
        var to = Square(from.row + step[0], from.col + step[1]);
        while (inside(to) && at(to) == null) {
          if (piece == Piece.king || !isRestricted(to)) {
            moves.add(Move(from, to));
          }
          to = Square(to.row + step[0], to.col + step[1]);
        }
      }
    }
    return moves;
  }

  bool allows(Move move) => moves.contains(move);

  /// The position after a move, with whatever it captured taken off and the
  /// game ended if it ended.
  Board play(Move move) {
    // Cheap, on purpose. The full check is [allows], and the search plays
    // hundreds of thousands of moves it generated itself; asking it to
    // generate them all again to confirm each one would cost more than the
    // search. The screen calls [allows] before it gets here.
    assert(
      at(move.from) != null && turn.owns(at(move.from)!),
      'no piece of the side to move on ${move.from}',
    );
    final squares = List<Piece?>.from(_squares);
    final piece = squares[move.from.row * size + move.from.col]!;
    squares[move.from.row * size + move.from.col] = null;
    squares[move.to.row * size + move.to.col] = piece;

    _takePieces(squares, move.to, piece);

    // Reaching a corner is the guards' whole plan, so it ends the game before
    // anything else is asked.
    if (piece == Piece.king && isCorner(move.to)) {
      return Board._(
        squares: squares,
        turn: turn.other,
        outcome: Outcome.kingAway,
      );
    }
    if (!squares.contains(Piece.king)) {
      return Board._(
        squares: squares,
        turn: turn.other,
        outcome: Outcome.kingTaken,
      );
    }

    final next = Board._(
      squares: squares,
      turn: turn.other,
      outcome: Outcome.none,
    );
    if (next.moves.isEmpty) {
      return Board._(
        squares: squares,
        turn: turn.other,
        outcome: Outcome.shutIn,
      );
    }
    return next;
  }

  /// Whoever won, or null while the game is still on.
  ///
  /// [Outcome.shutIn] is read against whose turn it is: the side with nothing
  /// to play is the side that lost.
  Side? get winner => switch (outcome) {
        Outcome.none => null,
        Outcome.kingAway => Side.guards,
        Outcome.kingTaken => Side.raiders,
        Outcome.shutIn => turn.other,
      };

  /// Takes whatever the piece that just landed on [at] has sandwiched.
  ///
  /// A piece is taken when an enemy moves in so that it is between two enemies
  /// along a row or column. It is never taken by moving between two enemies
  /// itself, which is what makes the game playable: without that rule half the
  /// board is poisoned and nobody can develop.
  ///
  /// A corner or the empty throne counts as an enemy for this, so a piece can
  /// be pinned against one. The throne only counts while it is empty — with
  /// the king sitting on it, it is the king, and the king is not an enemy of
  /// his own guards.
  static void _takePieces(List<Piece?> squares, Square at, Piece mover) {
    Piece? on(Square square) => squares[square.row * size + square.col];

    for (final step in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      final victim = Square(at.row + step[0], at.col + step[1]);
      final anvil = Square(at.row + step[0] * 2, at.col + step[1] * 2);
      if (victim.row < 0 || victim.row >= size) continue;
      if (victim.col < 0 || victim.col >= size) continue;
      if (anvil.row < 0 || anvil.row >= size) continue;
      if (anvil.col < 0 || anvil.col >= size) continue;

      final taken = on(victim);
      if (taken == null) continue;
      if (_friends(taken, mover)) continue;

      // The king is not taken by a sandwich. He is taken by being surrounded,
      // which is handled separately, because a king who could be pinched
      // between two raiders would never survive his first outing.
      if (taken == Piece.king) continue;

      final helper = on(anvil);
      final helps = helper != null
          ? _friends(helper, mover)
          : _hostileEmpty(anvil, squares);
      if (helps) squares[victim.row * size + victim.col] = null;
    }

    _takeKing(squares, mover);
  }

  /// The king comes off when every square around him is a raider or a hostile
  /// empty square — a corner, or the throne he has stepped off.
  ///
  /// On the edge of the board that is three sides rather than four, because
  /// the edge is the fourth. A king with his back to the wall is in more
  /// trouble than a king in the open, which is the opposite of what a rule
  /// counting only four-sided surrounds would say.
  static void _takeKing(List<Piece?> squares, Piece mover) {
    if (mover == Piece.guard || mover == Piece.king) return;

    var kingAt = -1;
    for (var i = 0; i < squares.length; i++) {
      if (squares[i] == Piece.king) kingAt = i;
    }
    if (kingAt < 0) return;
    final king = Square(kingAt ~/ size, kingAt % size);

    for (final step in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      final beside = Square(king.row + step[0], king.col + step[1]);
      if (beside.row < 0 || beside.row >= size) continue;
      if (beside.col < 0 || beside.col >= size) continue;

      final holding = squares[beside.row * size + beside.col];
      if (holding == Piece.raider) continue;
      if (holding == null && _hostileEmpty(beside, squares)) continue;
      return;
    }
    squares[kingAt] = null;
  }

  /// Whether an empty square helps take a piece standing next to it.
  static bool _hostileEmpty(Square square, List<Piece?> squares) {
    if (isCorner(square)) return true;
    if (square != throne) return false;
    // An occupied throne is the king standing on it, and he is nobody's anvil
    // against his own men.
    return squares[throne.row * size + throne.col] == null;
  }

  static bool _friends(Piece a, Piece b) {
    final left = a == Piece.raider;
    final right = b == Piece.raider;
    return left == right;
  }

  /// Two boards are the same position if the same men are on the same squares
  /// with the same side to move.
  ///
  /// Worth having so a game can notice it has been here before, which is the
  /// only thing standing between a cautious raider and shuffling one piece
  /// back and forth forever.
  @override
  bool operator ==(Object other) {
    if (other is! Board) return false;
    if (other.turn != turn || other.outcome != outcome) return false;
    for (var i = 0; i < _squares.length; i++) {
      if (other._squares[i] != _squares[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(turn, outcome, Object.hashAll(_squares));

  @override
  String toString() => [
        for (var row = 0; row < size; row++)
          [
            for (var col = 0; col < size; col++)
              switch (at(Square(row, col))) {
                Piece.raider => 'R',
                Piece.guard => 'G',
                Piece.king => 'K',
                null => Square(row, col) == throne ||
                        isCorner(Square(row, col))
                    ? '.'
                    : ' ',
              },
          ].join(),
      ].join('\n');
}
