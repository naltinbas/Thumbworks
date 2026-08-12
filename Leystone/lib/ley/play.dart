import 'green.dart';
import 'rules.dart';

/// A ring being raised. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.green, this.stones, this.before);

  factory Play.of(Green green) => Play._(green, const [], null);

  final Green green;

  /// The stones standing, in the order they were raised.
  final List<(int, int)> stones;

  final Play? before;

  bool get isDone => stones.length == green.asked;

  /// Whether a berth is free and clear of every ley.
  bool mayRaise((int, int) berth) =>
      !isDone &&
      !stones.contains(berth) &&
      Rules.leysWith(stones, berth) == null;

  /// The pair a berth would ley with, for the refusal to name.
  ((int, int), (int, int))? leyOf((int, int) berth) =>
      Rules.leysWith(stones, berth);

  /// One more stone.
  Play raise((int, int) berth) {
    if (!mayRaise(berth)) return this;
    return Play._(green, [...stones, berth], this);
  }

  /// Take a standing stone down.
  Play lower((int, int) berth) {
    if (!stones.contains(berth)) return this;
    return Play._(
        green,
        [
          for (final stone in stones)
            if (stone != berth) stone,
        ],
        this);
  }

  Play get back => before ?? this;

  /// A full ring growing from the standing stones, searched over
  /// every raising; null when none does.
  List<(int, int)>? get finished =>
      Rules.complete(green.size, stones, green.asked);

  /// The next berth of that ring, or null.
  (int, int)? nextOf(List<(int, int)> finished) {
    for (final berth in finished) {
      if (!stones.contains(berth)) return berth;
    }
    return null;
  }
}
