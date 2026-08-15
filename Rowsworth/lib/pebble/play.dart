import 'asking.dart';
import 'rules.dart';

/// An asking being met. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.asking, this.rules, this.heap, this.moves, this.before);

  factory Play.of(Asking asking) => Play._(asking, Rules(), null, 0, null);

  /// A play stood at a heap, for the mark and the tests.
  factory Play.standing(Asking asking, int heap) => Play._(asking, Rules(), heap, 1, null);

  final Asking asking;
  final Rules rules;

  /// The heap picked, or null.
  final int? heap;

  /// Picks made, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless asking admits it.
  static const gaveUpAt = 12;

  int get rows => heap == null ? 0 : Rules.rowsByTrial(heap!);

  List<int> get divisors => heap == null ? const [] : Rules.divisors(heap!);

  List<(int, int)> get factors => heap == null ? const [] : Rules.factors(heap!);

  bool get isDone => heap != null && rows == asking.rows;

  bool get gaveUp => !asking.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a heap off the board.
  Play pick(int n) {
    if (isOver || n < 1 || n > rules.most || n == heap) return this;
    return Play._(asking, rules, n, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The heap the show-me points at: the smallest on the board with
  /// the rows asked, or null.
  int? get next {
    if (isOver || !asking.winnable) return null;
    return asking.heaps.first;
  }
}
