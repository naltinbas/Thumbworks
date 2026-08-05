import 'boards.dart';
import 'play.dart';
import 'solve.dart';

/// A cell to go to next, and which thread should go there.
class Step {
  const Step({required this.thread, required this.at, required this.wrong});

  final int thread;
  final int at;

  /// Whether this is a cell to rub out rather than one to draw. A thread that
  /// has left the one way through has to come back to it first.
  final bool wrong;
}

/// Knows the answer to a board, and can say what to do next from wherever a
/// player has got to.
///
/// The answer is worked out once, when the board opens, and then only looked
/// at. That is what makes a hint honest: it is not a fresh search from the
/// half-finished board — it is the one way through, which is the same one it
/// was at the start, because there is only one.
class Guide {
  Guide(this.answer);

  factory Guide.of(Board board) =>
      Guide(Threader(board.field).ways(enough: 1).first!);

  /// The cells each thread runs through, in order.
  final List<List<int>> answer;

  /// The answer for a thread, the way round the player is drawing it.
  List<int> wayFor(Play play, int thread) {
    final want = answer[thread];
    return play.fromOf(thread) == want.first ? want : want.reversed.toList();
  }

  /// Whether a thread is going the way the answer goes, so far.
  bool isRight(Play play, int thread) {
    final path = play.pathOf(thread);
    final want = wayFor(play, thread);
    if (path.length > want.length) return false;
    for (var i = 0; i < path.length; i++) {
      if (path[i] != want[i]) return false;
    }
    return true;
  }

  /// The first cell a thread has that the answer does not, or -1.
  int wentWrongAt(Play play, int thread) {
    final path = play.pathOf(thread);
    final want = wayFor(play, thread);
    for (var i = 0; i < path.length; i++) {
      if (i >= want.length || path[i] != want[i]) return path[i];
    }
    return -1;
  }

  /// What to do next, or null when the board is finished.
  ///
  /// Threads that have wandered off come first, because a cell that is wrong
  /// is in somebody else's way and no amount of drawing elsewhere will fix
  /// it.
  Step? next(Play play) {
    for (var thread = 0; thread < answer.length; thread++) {
      final wrong = wentWrongAt(play, thread);
      if (wrong >= 0) return Step(thread: thread, at: wrong, wrong: true);
    }
    for (var thread = 0; thread < answer.length; thread++) {
      final path = play.pathOf(thread);
      final want = wayFor(play, thread);
      if (path.length == want.length) continue;
      return Step(thread: thread, at: want[path.length], wrong: false);
    }
    return null;
  }

  /// How many cells are on the answer but not yet drawn.
  int left(Play play) {
    var over = 0;
    for (var thread = 0; thread < answer.length; thread++) {
      final path = play.pathOf(thread);
      final want = wayFor(play, thread);
      var same = 0;
      while (same < path.length &&
          same < want.length &&
          path[same] == want[same]) {
        same++;
      }
      over += want.length - same;
    }
    return over;
  }
}
