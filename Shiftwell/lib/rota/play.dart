import 'rota.dart';
import 'rules.dart';

/// A rota being filled. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.rota, this.rules, this.filled, this.moves, this.before);

  factory Play.of(Rota rota) =>
      Play._(rota, Rules(4, rota.fixed), Map.of(rota.fixed), 0, null);

  /// A play stood at a fill, for the mark and the tests.
  factory Play.standing(Rota rota, Map<Shift, int> filled) =>
      Play._(rota, Rules(4, rota.fixed), Map.of(filled), 1, null);

  final Rota rota;
  final Rules rules;

  /// Every shift with a hand, the fixed ones among them.
  final Map<Shift, int> filled;

  /// Taps that changed a shift, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless rota admits it.
  static const gaveUpAt = 14;

  bool get isDone => rules.finished(filled);

  bool get gaveUp => !rota.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  List<Shift> get clashes => rules.clashes(filled);

  int get open => 16 - filled.length;

  bool isFixed(Shift shift) => rota.fixed.containsKey(shift);

  bool touches(Shift shift) =>
      !isOver && shift.$1 >= 0 && shift.$1 < 4 && shift.$2 >= 0 && shift.$2 < 4 &&
      !isFixed(shift);

  /// Taps a shift: the hand there goes up by one, 4 goes to none.
  Play tap(Shift shift) {
    if (!touches(shift)) return this;
    final held = Map.of(filled);
    final now = held[shift];
    if (now == null) {
      held[shift] = 1;
    } else if (now == 4) {
      held.remove(shift);
    } else {
      held[shift] = now + 1;
    }
    return Play._(rota, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: (shift, hand) toward the sweep's
  /// first finishing that agrees with every sound shift the
  /// player has set, or toward the fixed finishing when the
  /// player's shifts have strayed; null when nothing lands.
  (Shift, int)? get next {
    if (isOver || !rota.winnable) return null;
    final aim = rules.landing(rules.sound(filled) ? filled : rota.fixed) ??
        rules.landing(rota.fixed);
    if (aim == null) return null;
    for (final shift in rules.shifts) {
      if (isFixed(shift)) continue;
      if (filled[shift] != aim[shift]) return (shift, aim[shift]!);
    }
    return null;
  }
}
