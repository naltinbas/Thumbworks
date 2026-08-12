import 'rules.dart';
import 'stile.dart';

/// A stile being dialed. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.stile, this.stride, this.round, this.dials, this.before);

  factory Play.of(Stile stile) => Play._(stile, 1, 2, 0, null);

  /// A play stood at a dial, for the mark and the tests.
  factory Play.standing(Stile stile, int stride, int round) =>
      Play._(stile, stride, round, 0, null);

  final Stile stile;

  /// The dial as it stands: a stride over a round.
  final int stride;
  final int round;

  /// Dial turns taken.
  final int dials;

  final Play? before;

  /// The line past which the hopeless stile admits it.
  static const gaveUpAt = 12;

  List<int> get spots => Rules.spots(stride, round, stile.pegs);

  List<int> get gapsNow => Rules.gaps(stride, round, stile.pegs);

  int get sizeCount => Rules.sizeCount(stride, round, stile.pegs);

  /// Whether every peg landed its own hole.
  bool get allApart => spots.length == stile.pegs;

  bool get isDone => allApart && sizeCount == stile.asked;

  bool get gaveUp =>
      !stile.winnable && dials >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  Play _dialed(int stride, int round) =>
      Play._(stile, stride, round, dials + 1, this);

  /// Turn the stride up or down, kept inside the round.
  Play strideBy(int by) {
    if (isOver) return this;
    final turned = (stride + by).clamp(1, round - 1);
    if (turned == stride) return this;
    return _dialed(turned, round);
  }

  /// Turn the round up or down, to twelfths, the stride kept
  /// inside it.
  Play roundBy(int by) {
    if (isOver) return this;
    final turned = (round + by).clamp(2, 12);
    if (turned == round) return this;
    return _dialed(stride.clamp(1, turned - 1), turned);
  }

  Play get back => before ?? this;

  /// A dial that lands the asking, nearest the standing one first;
  /// null when none does.
  (int, int)? get next {
    final dials = Rules.dialsThatGive(stile.pegs, stile.asked);
    if (dials.isEmpty) return null;
    (int, int)? best;
    var nearest = 1 << 30;
    for (final (s, r) in dials) {
      final far = (s - stride).abs() + (r - round).abs();
      if (far < nearest) {
        nearest = far;
        best = (s, r);
      }
    }
    return best;
  }
}
