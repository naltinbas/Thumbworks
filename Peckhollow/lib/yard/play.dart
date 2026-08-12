import 'rules.dart';
import 'yard.dart';

/// A yard being reflipped. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.yard, this.arrows, this.flips, this.before);

  factory Play.of(Yard yard) => Play._(yard, yard.start, 0, null);

  final Yard yard;

  /// The arrows as they stand, one bit a pair.
  final int arrows;

  /// Flips taken.
  final int flips;

  final Play? before;

  /// The line past which a hopeless yard admits it.
  static const gaveUpAt = 8;

  List<int> get kings => Rules.kings(yard.birds, arrows);

  bool get isDone => yard.goalMet(kings);

  bool get gaveUp => !yard.winnable && flips >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether one bird pecks another, as the arrows stand.
  bool pecksOf(int one, int two) =>
      Rules.pecks(yard.birds, arrows)[one][two];

  /// Flip the arrow of the pair at [at].
  Play flip(int at) {
    if (isOver) return this;
    return Play._(yard, arrows ^ (1 << at), flips + 1, this);
  }

  Play get back => before ?? this;

  /// Fewest flips left to the crowning, walking every flipping; -1
  /// when no yard of this size ever meets it.
  int get toDone => Rules.flipsTo(yard.birds, arrows, yard.goalMet);

  /// A flip that starts a shortest road, or null.
  int? get next => isOver
      ? null
      : Rules.bestFlip(yard.birds, arrows, yard.goalMet);
}
