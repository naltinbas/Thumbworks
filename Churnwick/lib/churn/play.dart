import 'dairy.dart';
import 'fewest.dart';

/// A morning in the dairy part way through.
class Play {
  Play._(this.dairy, this.answer, this.standing, this.done, this.holding);

  factory Play.of(Dairy dairy, Measure answer) =>
      Play._(dairy, answer, dairy.empty, const [], -1);

  final Dairy dairy;

  /// The fewest goes there are, worked out when the morning opens.
  final Measure answer;

  /// How much is in each churn.
  final List<int> standing;

  /// Everything that has been done, in order.
  final List<Pour> done;

  /// The churn that has been picked up, or -1.
  final int holding;

  int get goes => done.length;

  int get fewest => answer.pours;

  int inChurn(int churn) => standing[churn];

  int roomIn(int churn) => dairy.churns[churn] - standing[churn];

  bool get isDone => dairy.isDone(standing);

  bool get isFewest => isDone && goes == fewest;

  /// Picks a churn up, or puts it down again.
  Play hold(int churn) => Play._(
        dairy,
        answer,
        standing,
        done,
        churn == holding || churn < 0 ? -1 : churn,
      );

  /// Does something, if it would change anything.
  Play doIt(Pour pour) {
    if (isDone || !pour.doesAnything(dairy, standing)) return this;
    return Play._(dairy, answer, pour.on(dairy, standing), [...done, pour], -1);
  }

  Play get back {
    if (done.isEmpty) return this;
    var walk = Play.of(dairy, answer);
    for (final pour in done.sublist(0, done.length - 1)) {
      walk = walk.doIt(pour);
    }
    return walk;
  }

  Play get again => Play.of(dairy, answer);

  /// The whole number every churn is a whole number of.
  int get stepOfDairy => Pouring.stepOf(dairy.churns);

  /// The fewest goes still to come from where the milk stands now.
  ///
  /// The same walk that answered the morning, started from here instead of
  /// from empty churns. A different question from the one answered when the
  /// morning opened, and no dearer, because a dairy has few enough
  /// arrangements to walk the whole of either way.
  Measure? get rest => Pouring.fewestFrom(dairy, standing);

  /// The best this morning can now come to, counting what has been done.
  int? get couldFinishIn {
    final left = rest;
    return left == null ? null : goes + left.pours;
  }

  /// Asked. The next thing to do that still finishes in as few goes as the
  /// morning can now be finished in.
  Pour? get next => rest?.how.firstOrNull;
}
