import 'level.dart';
import 'rules.dart';

/// A party being gathered. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.guests, this.moves, this.before);

  /// The party opens with one guest.
  factory Play.of(Level level) => Play._(level, 1, 0, null);

  /// A play stood at a count, for the mark and the tests.
  factory Play.standing(Level level, int guests) => Play._(level, guests, 0, null);

  final Level level;

  /// The guests gathered.
  final int guests;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  /// The chance of a shared day, exact.
  (BigInt, BigInt) get shared => Rules.shared(level.days, guests);

  /// The chance in a hundred, to two places.
  String get inHundred => Rules.inHundred(level.days, guests);

  bool get reaches => level.reaches(guests);

  bool get isDone => level.meets(guests);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Adds [by] guests, or takes them away, within one and the cap.
  Play turn(int by) {
    if (isOver) return this;
    final next = (guests + by).clamp(1, level.cap);
    if (next == guests) return this;
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the step toward the fewest, +10, +1,
  /// -1 or -10; null when nothing lands.
  int? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final gap = aim - guests;
    if (gap == 0) return null;
    if (gap >= 10) return 10;
    if (gap > 0) return 1;
    if (gap <= -10) return -10;
    return -1;
  }

  /// The fewest guests for the ask, kept once found.
  static int? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      int? found;
      for (var n = 1; n <= level.cap; n++) {
        if (level.meets(n)) {
          found = n;
          break;
        }
      }
      _aims[level.name] = found;
    }
    return _aims[level.name];
  }

  static final _aims = <String, int?>{};
}
