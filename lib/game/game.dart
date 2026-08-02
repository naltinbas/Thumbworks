import 'board.dart';

/// Why a game stopped without either side winning.
enum Drawn {
  /// Still going, or won by somebody.
  no,

  /// The same position for the third time. Somebody is shuffling.
  repeated,

  /// Nobody has taken anything or moved the king for a long while. The game
  /// is going nowhere and both sides know it.
  stale,
}

/// A game being played: the position, how it got there, and what came before.
///
/// The board is a position and knows nothing about the past. Repetition and
/// the going-nowhere rule are both about the past, so they live here.
class Game {
  const Game._({
    required this.board,
    required this.history,
    required this.moves,
    required this.drawn,
    required this.sinceProgress,
  });

  factory Game.fresh() {
    final board = Board.opening();
    return Game._(
      board: board,
      history: [board],
      moves: const [],
      drawn: Drawn.no,
      sinceProgress: 0,
    );
  }

  final Board board;

  /// Every position, opening first, so a move can be taken back and a
  /// repetition can be seen.
  final List<Board> history;

  /// The moves played, which is what the list beside the board reads from.
  final List<Move> moves;

  final Drawn drawn;

  /// Plies since a piece was taken or the king moved.
  ///
  /// Those are the only two things that make progress in this game. Raiders
  /// shuffling on the far side of the board while the guards shuffle back is
  /// not a position getting anywhere, however long it goes on.
  final int sinceProgress;

  /// How long without progress before it is called.
  ///
  /// Fifty plies is long enough that no real plan is cut short — a king walks
  /// the length of the board in three or four moves — and short enough that a
  /// game which has died does not have to be abandoned by the player instead.
  static const stalePlies = 50;

  int get played => moves.length;

  bool get isOver => board.isOver || drawn != Drawn.no;

  Side? get winner => board.winner;

  /// The game after a move.
  Game play(Move move) {
    final next = board.play(move);

    final took = _menOn(next) < _menOn(board);
    final kingMoved = board.at(move.from) == Piece.king;
    final since = took || kingMoved ? 0 : sinceProgress + 1;

    final seen = [...history, next];
    var why = Drawn.no;
    if (!next.isOver) {
      if (seen.where((was) => was == next).length >= 3) {
        why = Drawn.repeated;
      } else if (since >= stalePlies) {
        why = Drawn.stale;
      }
    }

    return Game._(
      board: next,
      history: seen,
      moves: [...moves, move],
      drawn: why,
      sinceProgress: since,
    );
  }

  /// The game one move ago, or this game if it has not started.
  ///
  /// Taking a move back also takes back a draw the move caused, which is why
  /// this rebuilds rather than keeping a stack of games: a game is entirely
  /// determined by its moves, so there is nothing else to restore.
  Game get back {
    if (moves.isEmpty) return this;
    var game = Game.fresh();
    for (final move in moves.take(moves.length - 1)) {
      game = game.play(move);
    }
    return game;
  }

  /// Both moves back, which is what a player who wants their move back
  /// actually wants when the other side has already replied.
  Game get backAPair => moves.length < 2 ? Game.fresh() : back.back;

  static int _menOn(Board board) =>
      board.count(Piece.raider) + board.count(Piece.guard) + board.count(Piece.king);
}
