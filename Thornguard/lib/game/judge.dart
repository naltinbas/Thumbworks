import 'board.dart';

/// What a position is worth, in hundredths of a raider.
///
/// Always from the raiders' side: positive is good for the raiders, negative
/// is good for the guards. One number, one direction, so there is one place
/// for a sign to be wrong instead of two.
class Judge {
  const Judge();

  /// A win. Far outside anything the terms below can reach, so no amount of
  /// material is ever worth losing the king over.
  static const won = 1000000;

  /// What each man is worth.
  ///
  /// A guard is worth more than a raider because there are a quarter as many
  /// of them and each one is a wall the king needs. Trading one for one is a
  /// good deal for the raiders and the numbers should say so.
  static const _raider = 100;
  static const _guard = 240;

  /// A corner the king can reach in one move.
  ///
  /// Two of them is the game. The raiders can block one clear path in a move
  /// and not two, so a king with two open corners has already won and the
  /// score has to be big enough that no search trades material for it.
  static const _oneRoute = 900;
  static const _twoRoutes = won ~/ 2;

  /// Every square nearer the edge the king gets.
  ///
  /// The guards' whole plan is a walk to a corner, so a king in the middle is
  /// a king who has not started. This is deliberately small: it points the
  /// guards in the right direction without making them run the king out alone
  /// into the open, which loses.
  static const _kingOut = 14;

  /// A raider standing next to the king. Three of them is a threat and four
  /// is the game, so each one is worth having.
  static const _closingIn = 45;

  /// The score, always from the raiders' point of view.
  int of(Board board) {
    switch (board.outcome) {
      case Outcome.kingAway:
        return -won;
      case Outcome.kingTaken:
        return won;
      case Outcome.shutIn:
        return board.winner == Side.raiders ? won : -won;
      case Outcome.none:
        break;
    }

    var score = board.count(Piece.raider) * _raider -
        board.count(Piece.guard) * _guard;

    final king = board.kingAt;
    if (king == null) return won;

    final routes = _openCorners(board, king);
    if (routes >= 2) {
      score -= _twoRoutes;
    } else if (routes == 1) {
      score -= _oneRoute;
    }

    // How far out the king has walked, measured as how close he is to the
    // nearest edge rather than to a corner: a king on an edge is one clear
    // run from home, and which edge he is on hardly matters.
    final fromEdge = [
      king.row,
      king.col,
      Board.size - 1 - king.row,
      Board.size - 1 - king.col,
    ].reduce((a, b) => a < b ? a : b);
    score += fromEdge * _kingOut;

    var beside = 0;
    for (final step in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      final at = Square(king.row + step[0], king.col + step[1]);
      if (!board.inside(at)) continue;
      if (board.at(at) == Piece.raider) beside++;
    }
    score += beside * _closingIn;

    return score;
  }

  /// How many corners the king could walk to right now, over nothing.
  static int _openCorners(Board board, Square king) {
    var open = 0;
    for (final corner in Board.corners) {
      if (corner.row != king.row && corner.col != king.col) continue;
      if (!_clear(board, king, corner)) continue;
      open++;
    }
    return open;
  }

  static bool _clear(Board board, Square from, Square to) {
    final rowStep = (to.row - from.row).sign;
    final colStep = (to.col - from.col).sign;
    var at = Square(from.row + rowStep, from.col + colStep);
    while (at != to) {
      if (board.at(at) != null) return false;
      at = Square(at.row + rowStep, at.col + colStep);
    }
    return board.at(to) == null;
  }
}
