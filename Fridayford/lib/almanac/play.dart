import 'level.dart';
import 'rules.dart';

/// A year being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.start, this.isLeap, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.startDay, false, 0, null);

  /// A play stood at a kind of year, for the mark and the tests.
  factory Play.standing(Level level, int start, bool isLeap) => Play._(level, start, isLeap, 0, null);

  final Level level;

  /// The day of the week the year begins on, nought for Monday.
  final int start;

  /// Whether the year is leap.
  final bool isLeap;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it: every kind seen.
  static const gaveUpAt = 14;

  List<int> get thirteenths => Rules.thirteenths(start, isLeap);

  List<int> get fridays => Rules.fridays(start, isLeap);

  bool get isDone => level.meets(fridays);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Moves the first of January on a day.
  Play get nextDay => isOver ? this : Play._(level, (start + 1) % 7, isLeap, moves + 1, this);

  /// Makes the year leap, or common again.
  Play get toggleLeap => isOver ? this : Play._(level, start, !isLeap, moves + 1, this);

  Play get back => before ?? this;

  /// What the show-me points at: 'leap' when the year must change kind
  /// to reach the nearest kind that meets the ask, else 'day'; null when
  /// nothing lands.
  String? get next {
    if (isOver || !level.winnable) return null;
    // The fewest taps to a kind that meets the ask: days forward, with or
    // without a change of leap.
    var bestTaps = 99;
    String? bestFirst;
    for (final leapNow in [isLeap, !isLeap]) {
      for (var d = 0; d < 7; d++) {
        final s = (start + d) % 7;
        if (!level.meets(Rules.fridays(s, leapNow))) continue;
        final taps = d + (leapNow == isLeap ? 0 : 1);
        if (taps < bestTaps) {
          bestTaps = taps;
          bestFirst = leapNow == isLeap ? 'day' : 'leap';
        }
      }
    }
    return bestFirst;
  }
}
