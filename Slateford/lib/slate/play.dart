import 'book.dart';
import 'level.dart';
import 'rules.dart';

/// A slate being played. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.board, this.moves, this.before, this.bookCell, this.bookRule);

  factory Play.of(Level level) {
    var board = List.of(level.start);
    int? cell;
    String? rule;
    if (!Rules.over(board) && Rules.toMove(board) != level.side) {
      (cell, rule) = Book.advise(board);
      board = Rules.played(board, cell, Rules.toMove(board));
    }
    return Play._(level, board, 0, null, cell, rule);
  }

  /// A play stood at a slate, for the mark and the tests.
  factory Play.standing(Level level, Board board) =>
      Play._(level, List.of(board), 0, null, null, null);

  final Level level;
  final Board board;

  /// Your marks made, counted.
  final int moves;

  final Play? before;

  /// The book's last cell and the rule that chose it, or null.
  final int? bookCell;
  final String? bookRule;

  int get side => level.side;
  int get bookSide => 3 - level.side;

  bool get isOver => Rules.over(board);

  int get winner => Rules.winner(board);

  bool get won => winner == side;
  bool get lost => winner == bookSide;
  bool get drawn => isOver && winner == 0;

  bool get isDone => level.win ? won : drawn;

  bool get gaveUp => !level.winnable && isOver && !isDone;

  /// The tree's word from your side: one, nought or minus one.
  int get value {
    if (won) return 1;
    if (lost) return -1;
    if (drawn) return 0;
    final v = Rules.value(board);
    return Rules.toMove(board) == side ? v : -v;
  }

  bool touches(int cell) => !isOver && cell >= 0 && cell < 9 && board[cell] == 0;

  /// Marks a cell, and the book answers at once.
  Play tap(int cell) {
    if (!touches(cell)) return this;
    var next = Rules.played(board, cell, side);
    int? bc;
    String? br;
    if (!Rules.over(next)) {
      (bc, br) = Book.advise(next);
      next = Rules.played(next, bc, bookSide);
    }
    return Play._(level, next, moves + 1, this, bc, br);
  }

  Play get back => before ?? this;

  /// What the show-me points at: a cell that keeps the tree's word.
  int? get next {
    if (isOver || !level.winnable) return null;
    final best = Rules.bestMoves(board);
    return best.isEmpty ? null : best.first;
  }
}
