import 'package:thornguard/game/board.dart';

/// The rules again, written the slow obvious way.
///
/// This shares no code with the game. Where the game walks outwards from each
/// piece and stops when it hits something, this asks of every pair of squares
/// on the board whether a move between them would be legal, by reading the
/// rules off one at a time. It is quadratic in the number of squares and it
/// would be a silly way to run a search.
///
/// That is the point. Two implementations that agree are worth more than one
/// that passes the tests its author thought of, and this one is slow enough to
/// be obviously right.
List<Move> movesPlainly(Board board) {
  if (board.isOver) return const [];
  final moves = <Move>[];

  for (var fromRow = 0; fromRow < Board.size; fromRow++) {
    for (var fromCol = 0; fromCol < Board.size; fromCol++) {
      final from = Square(fromRow, fromCol);
      final piece = board.at(from);
      if (piece == null || !board.turn.owns(piece)) continue;

      for (var toRow = 0; toRow < Board.size; toRow++) {
        for (var toCol = 0; toCol < Board.size; toCol++) {
          final to = Square(toRow, toCol);
          if (to == from) continue;

          // Along a row or a column, never a diagonal.
          if (toRow != fromRow && toCol != fromCol) continue;

          // Over nothing, and onto nothing.
          if (!_clearBetween(board, from, to)) continue;
          if (board.at(to) != null) continue;

          // Only the king may finish on a corner or the throne.
          if (piece != Piece.king && Board.isRestricted(to)) continue;

          moves.add(Move(from, to));
        }
      }
    }
  }
  return moves;
}

bool _clearBetween(Board board, Square from, Square to) {
  final rowStep = (to.row - from.row).sign;
  final colStep = (to.col - from.col).sign;
  var at = Square(from.row + rowStep, from.col + colStep);
  while (at != to) {
    if (board.at(at) != null) return false;
    at = Square(at.row + rowStep, at.col + colStep);
  }
  return true;
}

/// How many positions there are [depth] moves from here, counting the leaves.
///
/// The count of a game tree is the one number that catches a rule written
/// slightly wrong. A generator that allows one illegal move, or forgets one
/// legal one, or captures a piece it should not, changes this number — and it
/// changes it by an amount that grows with depth, so a bug too rare to trip a
/// hand written test shows up here as a mismatch of thousands.
int perft(Board board, int depth) {
  if (depth == 0) return 1;
  if (board.isOver) return 1;
  final moves = board.moves;
  if (depth == 1) return moves.length;

  var total = 0;
  for (final move in moves) {
    total += perft(board.play(move), depth - 1);
  }
  return total;
}
