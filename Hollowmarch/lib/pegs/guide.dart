import 'boards.dart';
import 'field.dart';
import 'play.dart';
import 'rule_of_three.dart';
import 'solve.dart';

/// Knows whether a position can still be finished, and what to do next.
///
/// Two things answer that, and the cheap one goes first. The rule of three is
/// a pair of sums over the pegs and settles a great many positions on its own
/// — a board whose sums match no hollow at all can never come down to one
/// peg, whatever anybody does next. Only when the sums still allow something
/// is the search asked, and the search is given a budget, because on the big
/// board there are positions nothing here could settle.
class Guide {
  Guide(this.board, {this.give = 250000})
      : field = board.field,
        _rule = RuleOfThree(board.field);

  final Board board;
  final Field field;

  /// How many positions a search may look at before it says it cannot see.
  final int give;

  final RuleOfThree _rule;

  /// The hollows a position could still come down to, by the rule of three
  /// alone. Empty means it certainly cannot be finished.
  List<int> couldFinish(int pegs) => _rule.couldFinish(pegs);

  /// Whether the position can still be brought down to one peg: true, false,
  /// or null for "cannot see from here".
  bool? canStillFinish(int pegs) {
    if (Solver.count(pegs) == 1) return true;
    if (couldFinish(pegs).isEmpty) return false;
    return Solver(field, give: give).canFinish(pegs);
  }

  /// A way from here down to one peg, or null if there is none or the search
  /// could not see one.
  Route? routeFrom(int pegs) {
    if (couldFinish(pegs).isEmpty) return null;
    return Solver(field, give: give).from(pegs);
  }

  /// The jump to make next, or null.
  Jump? next(Play play) {
    final route = routeFrom(play.pegs);
    if (route == null || route.jumps.isEmpty) return null;
    // Part way through a move, only that peg may move, so a hint has to be
    // about that peg or it is advice for a game nobody is playing.
    if (play.carrying >= 0 && route.jumps.first.from != play.carrying) {
      final mine = Solver(field, give: give);
      for (final jump in play.canJump) {
        if (mine.canFinish(Solver.after(play.pegs, jump)) ?? false) return jump;
      }
      return null;
    }
    return route.jumps.first;
  }
}
