import 'level.dart';
import 'rules.dart';

/// A board being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.kings, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [], 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, List<int> kings) =>
      Play._(level, level.rules, List.of(kings), kings.length, null);

  final Level level;
  final Rules rules;

  /// The squares with kings, in the order set.
  final List<int> kings;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless board admits it.
  static const gaveUpAt = 13;

  List<(int, int)> get clashes => rules.clashes(kings);

  bool has(int c) => kings.contains(c);

  bool get isDone => rules.lands(kings, level.kings);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int c) => !isOver && c >= 0 && c < rules.squares;

  /// Taps a square: sets a king, or lifts the one there.
  Play tap(int c) {
    if (!touches(c)) return this;
    final next = has(c) ? [for (final k in kings) if (k != c) k] : [...kings, c];
    return Play._(level, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', square) for a king off the
  /// even-squares setting, else ('set', square) for the first square of it
  /// with no king; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    for (final k in kings) {
      if (!aim.contains(k)) return ('lift', k);
    }
    for (final c in aim) {
      if (!has(c)) return ('set', c);
    }
    return null;
  }

  /// The even-squares setting, kept once found: the even squares, or
  /// its first kings when the board asks for fewer.
  static List<int> aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final colour = level.rules.evens;
      _aims[level.name] = colour.sublist(0, level.kings < colour.length ? level.kings : colour.length);
    }
    return _aims[level.name]!;
  }

  static final _aims = <String, List<int>>{};
}
