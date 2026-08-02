import 'field.dart';
import 'play.dart';
import 'reason.dart';

/// What happened when a board was reasoned through.
class Solved {
  const Solved({
    required this.cleared,
    required this.hardest,
    required this.steps,
    required this.left,
  });

  /// Whether reasoning alone finished the board.
  final bool cleared;

  /// The hardest rule it took. A board that never needed more than counting
  /// is a different game from one that needed the third rule, and this is how
  /// the difference is measured rather than guessed at.
  final Rule hardest;

  /// How many separate deductions it took.
  final int steps;

  /// How many squares were still shut when it ran out of things to prove.
  final int left;
}

/// Plays a board through by reasoning alone, and never guesses.
///
/// Stops the moment nothing more follows from what is on the board. That
/// stopping point is the whole point: a board that stops short of finished is
/// a board that would have asked a player to toss a coin, and it is thrown
/// away rather than shipped.
Solved reasonThrough(Field field, {Rule upTo = Rule.whole}) {
  var play = Play.of(field);
  final known = <int>{};
  var hardest = Rule.counted;
  var steps = 0;

  while (!play.isOver) {
    final step = Reasoner(play, upTo: upTo, known: known).step;
    if (step == null) break;
    if (step.isEmpty) break;

    if (step.rule.index > hardest.index) hardest = step.rule;
    steps++;
    known.addAll(step.mined);
    for (final at in step.safe) {
      play = play.open(at);
    }
  }

  return Solved(
    cleared: play.ending == Ending.cleared,
    hardest: hardest,
    steps: steps,
    left: play.toGo,
  );
}
