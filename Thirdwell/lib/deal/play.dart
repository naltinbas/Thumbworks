import 'rules.dart';
import 'walk.dart';

/// A walk being dealt. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.walk, this.rules, this.placings, this.moves, this.before);

  factory Play.of(Walk walk) => Play._(walk, Rules(deals: walk.deals), const [], 0, null);

  /// A play stood at a run of placings, for the mark and the tests.
  factory Play.standing(Walk walk, List<int> placings) =>
      Play._(walk, Rules(deals: walk.deals), List.of(placings), placings.length, null);

  final Walk walk;
  final Rules rules;

  /// The placings made so far, 0 top, 1 middle, 2 bottom.
  final List<int> placings;

  /// Placings made, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless walk admits it: its deals
  /// all made.
  int get gaveUpAt => walk.deals;

  /// The stack as it stands after the placings so far.
  List<int> get stack => Rules.run(walk.chosen, placings);

  /// The columns the standing stack deals into, for the next
  /// placing.
  List<List<int>> get columns => Rules.dealOut(stack);

  /// Which column holds the counter now.
  int get holding => columns.indexWhere((c) => c.contains(walk.chosen));

  /// The counter's place in the standing stack, nought from top.
  int get place => stack.indexOf(walk.chosen);

  bool get dealsDone => placings.length == walk.deals;

  bool get isDone => dealsDone && place == walk.place;

  bool get gaveUp => !walk.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a placing may be made: deals left.
  bool touches(int placing) => !isOver && !dealsDone && placing >= 0 && placing < 3;

  /// Gathers the columns with the counter's column at [placing].
  Play gather(int placing) {
    if (!touches(placing)) return this;
    return Play._(walk, rules, [...placings, placing], moves + 1, this);
  }

  Play get back => before ?? this;

  /// The placing the show-me points at: the next of Gergonne's run
  /// for the place asked, or null when the placings so far have
  /// strayed from it or nothing lands.
  int? get next {
    if (isOver || !walk.winnable) return null;
    final aim = rules.landing(walk.chosen, walk.place);
    if (aim == null) return null;
    for (var i = 0; i < placings.length; i++) {
      if (placings[i] != aim[i]) return null;
    }
    return placings.length < aim.length ? aim[placings.length] : null;
  }
}
