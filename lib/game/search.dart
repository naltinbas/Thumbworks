import 'board.dart';
import 'judge.dart';

/// What the search decided, and what it cost.
class Thought {
  const Thought({
    required this.move,
    required this.score,
    required this.depth,
    required this.positions,
  });

  /// The move to play, or null if the side to move has none.
  final Move? move;

  /// What the position is worth to the side that is about to move.
  final int score;

  /// How deep it got. Iterative deepening means this is a result, not a
  /// setting: the clock decides.
  final int depth;

  /// How many positions were looked at. The number that says whether the
  /// pruning is working.
  final int positions;

  /// Whether the search believes the game is already decided.
  bool get isDecided => score.abs() > Judge.won ~/ 2;
}

/// Picks a move.
///
/// Alpha-beta over an evaluation, deepened a ply at a time until the clock
/// runs out. Iterative deepening looks wasteful — every depth redoes the work
/// of the one before — and is not: the shallow searches cost a fraction of the
/// deep one, and the move they liked best is tried first at the next depth,
/// which is what makes alpha-beta cut as much as it does.
///
/// Nothing here is random. The same position at the same strength gives the
/// same move, which is what lets a test say the opponent found a mate rather
/// than that it usually does.
class Search {
  const Search({required this.depth, this.judge = const Judge()});

  /// How deep to look, in plies. This is the difficulty dial.
  final int depth;

  final Judge judge;

  /// The best move for whoever is to move.
  Thought think(Board board) {
    var best = const Thought(move: null, score: 0, depth: 0, positions: 0);
    var positions = 0;

    // The move liked at the last depth, tried first at the next one.
    Move? first;

    for (var reach = 1; reach <= depth; reach++) {
      final at = _Run(judge: judge, first: first);
      final found = at.best(board, reach);
      positions += at.positions;
      if (found.move == null) break;

      first = found.move;
      best = Thought(
        move: found.move,
        score: found.score,
        depth: reach,
        positions: positions,
      );

      // A forced win or loss will not change its mind with another ply, and
      // the search has better things to do than confirm it four more times.
      if (best.isDecided) break;
    }

    return best;
  }
}

/// One depth of one search.
class _Run {
  _Run({required this.judge, this.first});

  final Judge judge;
  final Move? first;

  int positions = 0;

  ({Move? move, int score}) best(Board board, int reach) {
    final moves = _ordered(board);
    if (moves.isEmpty) return (move: null, score: 0);

    Move? best;
    var alpha = -Judge.won * 2;
    for (final move in moves) {
      final score = -_negamax(board.play(move), reach - 1, -Judge.won * 2, -alpha);
      if (best == null || score > alpha) {
        best = move;
        alpha = score;
      }
    }
    return (move: best, score: alpha);
  }

  /// The value of a position to the side about to move in it.
  ///
  /// Negamax rather than a pair of mirror-image routines, because two copies
  /// of the same logic with the signs flipped is two places for a sign to be
  /// wrong.
  int _negamax(Board board, int reach, int alpha, int beta) {
    positions++;
    if (board.isOver || reach == 0) {
      final raiders = judge.of(board);
      return board.turn == Side.raiders ? raiders : -raiders;
    }

    final moves = _ordered(board);
    if (moves.isEmpty) {
      // Cannot happen: a board with no moves is over and was caught above.
      // Here so that a future rule change is a failed test rather than a
      // silently wrong score.
      assert(false, 'a position with no moves should be over');
      return -Judge.won;
    }

    var score = -Judge.won * 2;
    for (final move in moves) {
      final value = -_negamax(board.play(move), reach - 1, -beta, -alpha);
      if (value > score) score = value;
      if (score > alpha) alpha = score;
      if (alpha >= beta) break;
    }
    return score;
  }

  /// The moves, with the ones worth looking at first, first.
  ///
  /// Alpha-beta only cuts when it sees a good move early, so the order matters
  /// more than almost anything else in here. The order is: whatever the last
  /// depth liked, then the king's moves, then anything that takes a piece.
  List<Move> _ordered(Board board) {
    final moves = board.moves;
    if (moves.length < 2) return moves;

    final king = board.kingAt;
    int rank(Move move) {
      if (move == first) return 0;
      if (king != null && move.from == king) return 1;
      if (_takes(board, move)) return 2;
      return 3;
    }

    final ranked = List<Move>.from(moves)
      ..sort((a, b) => rank(a).compareTo(rank(b)));
    return ranked;
  }

  /// Whether a move lands next to an enemy with a friend on the far side,
  /// which is the shape of every capture in this game.
  ///
  /// A guess, not a rule: it says nothing about the king and nothing about
  /// hostile corners. It only has to be right often enough to sort the list,
  /// and being cheap matters more than being exact, because it runs on every
  /// move of every position.
  static bool _takes(Board board, Move move) {
    final mover = board.at(move.from);
    if (mover == null) return false;
    for (final step in const [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
      final victim = Square(move.to.row + step[0], move.to.col + step[1]);
      final anvil = Square(move.to.row + step[0] * 2, move.to.col + step[1] * 2);
      if (!board.inside(victim) || !board.inside(anvil)) continue;
      final taken = board.at(victim);
      if (taken == null) continue;
      if (board.turn.owns(taken)) continue;
      final helper = board.at(anvil);
      if (helper != null && board.turn.owns(helper)) return true;
      if (helper == null && Board.isCorner(anvil)) return true;
    }
    return false;
  }
}
