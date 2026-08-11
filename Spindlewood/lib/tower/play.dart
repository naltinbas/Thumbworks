import 'rules.dart';
import 'spindle.dart';

/// A tower being moved. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.spindle, this.rules, this.board, this.made, this.before);

  Play.of(Spindle spindle)
      : this._(spindle, _rulesFor(spindle), 0, 0, null);

  final Spindle spindle;
  final Rules rules;

  /// Where every round sits.
  final int board;

  /// Moves made so far.
  final int made;

  final Play? before;

  static final _kept = <(int, int), Rules>{};

  static Rules _rulesFor(Spindle spindle) =>
      _kept[(spindle.spindles, spindle.rounds)] ??=
          Rules(spindle.spindles, spindle.rounds);

  bool get isHome => board == rules.home;

  /// The smallest round on a spindle, or null.
  int? topOf(int at) => rules.topOf(board, at);

  int spindleOf(int round) => rules.spindleOf(board, round);

  /// Whether the top of one spindle may land on another.
  bool mayMove(int from, int to) {
    final round = topOf(from);
    return round != null && rules.mayMove(board, round, to);
  }

  /// Moves the top of one spindle onto another. The board comes back
  /// unchanged if it may not.
  Play move(int from, int to) {
    if (isHome || !mayMove(from, to)) return this;
    return Play._(spindle, rules,
        rules.moved(board, topOf(from)!, to), made + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest moves home from here.
  int get fewestFromHere => rules.fewest(board);

  /// A move that steps one nearer home: the spindles it leaves and
  /// lands on, or null at home.
  (int, int)? get next {
    final move = rules.next(board);
    if (move == null) return null;
    final (round, to) = move;
    return (rules.spindleOf(board, round), to);
  }
}
