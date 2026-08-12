import 'rules.dart';
import 'worth.dart';

/// A rack being chosen from. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.worth, this.chosen, this.moves, this.before);

  factory Play.of(Worth worth) => Play._(worth, const [], 0, null);

  /// A play stood at a choice, for the mark and the tests.
  factory Play.standing(Worth worth, List<int> chosen) =>
      Play._(worth, List.of(chosen), chosen.length, null);

  final Worth worth;

  /// The weights chosen, in choosing order.
  final List<int> chosen;

  /// Choosings and puttings-back, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless worth admits it.
  static const gaveUpAt = 14;

  (List<int>, List<int>)? get balanced => Rules.balance(chosen);

  bool get isDone =>
      chosen.length == worth.choose && balanced == null;

  bool get gaveUp => !worth.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Chooses a weight from the rack, or puts it back.
  Play tapAt(int weight) {
    if (isOver || !Rules.rack.contains(weight)) return this;
    if (chosen.contains(weight)) {
      return Play._(worth,
          [for (final held in chosen) if (held != weight) held],
          moves + 1, this);
    }
    if (chosen.length == worth.choose) return this;
    return Play._(worth, [...chosen, weight], moves + 1, this);
  }

  Play get back => before ?? this;

  /// The weight the sweep would move next towards a clean
  /// choice; null when none lands the asking.
  (int, bool)? get next {
    final aim = Rules.choice(worth.choose);
    if (aim == null || isDone) return null;
    for (final weight in chosen) {
      if (!aim.contains(weight)) return (weight, false);
    }
    for (final weight in aim) {
      if (!chosen.contains(weight)) return (weight, true);
    }
    return null;
  }
}
