import 'dart:math';
import 'dart:typed_data';

import 'boards.dart';
import 'lock.dart';
import 'marks.dart';

/// One guess, and what it came back as.
class Try {
  const Try({required this.guess, required this.mark, required this.left});

  final int guess;
  final Mark mark;

  /// How many codes were still possible after it.
  final int left;
}

/// A game against one lock.
///
/// Immutable. Every guess gives a new one, which is what lets a test play a
/// whole game as an expression and lets the screen look back over a list of
/// tries nothing has been able to change.
class Play {
  const Play._({
    required this.board,
    required this.marks,
    required this.secret,
    required this.tries,
    required this.could,
  });

  factory Play.of(Board board, Marks marks, {int? secret, Random? dice}) =>
      Play._(
        board: board,
        marks: marks,
        secret: secret ?? (dice ?? Random()).nextInt(board.codes),
        tries: const [],
        could: marks.everything,
      );

  final Board board;
  final Marks marks;

  /// The code. Nothing on the screen may read this until the game is over,
  /// and nothing that decides anything reads it at all.
  final int secret;

  final List<Try> tries;

  /// Every code still consistent with what has come back so far.
  ///
  /// This is the whole of what a player knows, and it is worked out from the
  /// marks rather than from the code — so it is exactly what a player could
  /// work out themselves with enough paper.
  final Int32List could;

  Lock get lock => board.lock;

  bool get isOpen =>
      tries.isNotEmpty && tries.last.mark.blacks == lock.pegs;

  /// How many guesses are left. The promise on the board is the whole
  /// allowance: that many is always enough, so that many is what you get.
  int get left => board.inside - tries.length;

  bool get isLost => !isOpen && left <= 0;
  bool get isOver => isOpen || isLost;

  /// This game with a guess made.
  Play tried(int guess) {
    if (isOver) return this;
    final mark = lock.markOf(secret, guess);
    final next = marks.narrow(could, guess, mark.asOne(lock));
    return Play._(
      board: board,
      marks: marks,
      secret: secret,
      tries: [
        ...tries,
        Try(guess: guess, mark: mark, left: next.length),
      ],
      could: next,
    );
  }
}
