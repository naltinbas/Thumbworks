import 'quire.dart';
import 'rules.dart';

/// A weaving in progress. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.quire, this.stack, this.weaves, this.before);

  factory Play.of(Quire quire) =>
      Play._(quire, List.of(quire.start), 0, null);

  final Quire quire;

  /// The leaves as they lie, top first.
  final List<int> stack;

  /// Weaves taken.
  final int weaves;

  final Play? before;

  /// The line past which a hopeless quire admits it.
  static const gaveUpAt = 8;

  bool get isDone => quire.isDone(stack);

  bool get gaveUp => !quire.winnable && weaves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Where the plate lies, counted from the top.
  int get plateAt => stack.indexOf(0);

  /// One weave, in or out.
  Play step(bool inward) {
    if (isOver) return this;
    return Play._(
        quire, Rules.weave(stack, inward), weaves + 1, this);
  }

  Play get back => before ?? this;

  /// Fewest weaves left from here, walking every weaving; -1 when no
  /// weaving ever settles it.
  int get toDone => Rules.fewest(stack, quire.isDone);

  /// The weave the walk closes with: true for in, false for out,
  /// null when nothing helps or the task is settled.
  bool? get next =>
      isOver ? null : Rules.bestWeave(stack, quire.isDone);
}
