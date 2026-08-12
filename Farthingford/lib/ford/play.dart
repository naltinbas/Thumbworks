import 'reach.dart';
import 'rules.dart';

/// A wade in progress. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.reach, this.bankA, this.bankC, this.wades, this.before,
      {this.landed = false});

  factory Play.of(Reach reach) =>
      Play._(reach, reach.startA, reach.startC, 0, null);

  final Reach reach;

  /// The banks held now, left and right.
  final (int, int) bankA;
  final (int, int) bankC;

  /// Mediants taken.
  final int wades;

  final Play? before;

  /// The line past which a hopeless reach admits it.
  static const gaveUpAt = 8;

  /// The stone between the banks.
  (int, int) get stone => Rules.mediant(
      bankA.$1, bankA.$2, bankC.$1, bankC.$2);

  /// Whether the stone is the ford asked for.
  bool get stoneIsTarget {
    final target = reach.target;
    if (target == null) return false;
    return stone.$1 * target.$2 == target.$1 * stone.$2;
  }

  /// Whether the crossing has been claimed and stood.
  final bool landed;

  bool get isDone => landed;

  bool get gaveUp =>
      !reach.winnable && wades >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether the target still lies between the banks (always true
  /// when wading has kept to the rule).
  bool get holdsTarget {
    final target = reach.target;
    if (target == null) return true;
    final (tp, tq) = target;
    return tp * bankA.$2 >= bankA.$1 * tq &&
        bankC.$1 * tq >= tp * bankC.$2;
  }

  /// Step onto the stone and keep the left reach.
  Play wadeLeft() {
    if (isOver) return this;
    return Play._(reach, bankA, stone, wades + 1, this);
  }

  /// Step onto the stone and keep the right reach.
  Play wadeRight() {
    if (isOver) return this;
    return Play._(reach, stone, bankC, wades + 1, this);
  }

  /// Claim the stone as the crossing.
  Play cross() {
    if (isOver || !stoneIsTarget) return this;
    return Play._(reach, bankA, bankC, wades + 1, this,
        landed: true);
  }

  Play get back => before ?? this;

  /// What the true walk does here: 'left', 'right', or 'cross';
  /// null when the reach is hopeless or the wade has lost the
  /// target.
  String? get next {
    final target = reach.target;
    if (target == null || isOver || !holdsTarget) return null;
    if (stoneIsTarget) return 'cross';
    final (tp, tq) = target;
    final (p, q) = stone;
    return tp * q < p * tq ? 'left' : 'right';
  }
}
