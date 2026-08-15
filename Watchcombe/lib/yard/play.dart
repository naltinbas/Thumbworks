import 'level.dart';
import 'rules.dart';

/// A yard being watched. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.watchmen, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [], 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, List<int> watchmen) =>
      Play._(level, level.rules, List.of(watchmen), watchmen.length, null);

  final Level level;
  final Rules rules;

  /// The flags with watchmen, in the order posted.
  final List<int> watchmen;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless yard admits it.
  static const gaveUpAt = 13;

  List<int> get unwatched => rules.unwatched(watchmen);

  bool has(int c) => watchmen.contains(c);

  bool get isDone => rules.lands(watchmen, level.watchmen);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int c) => !isOver && c >= 0 && c < rules.flags;

  /// Taps a flag: posts a watchman, or lifts the one there.
  Play tap(int c) {
    if (!touches(c)) return this;
    final next = has(c) ? [for (final k in watchmen) if (k != c) k] : [...watchmen, c];
    return Play._(level, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', square) for a watchman off the
  /// posting one in from the far flags, else ('set', square) for the first flag of it
  /// with no watchman; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    for (final k in watchmen) {
      if (!aim.contains(k)) return ('lift', k);
    }
    for (final c in aim) {
      if (!has(c)) return ('set', c);
    }
    return null;
  }

  /// The posting one in from the far flags, kept once found, or
  /// its first watchmen when the board asks for fewer.
  static List<int> aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final colour = level.rules.posting;
      _aims[level.name] = colour.sublist(0, level.watchmen < colour.length ? level.watchmen : colour.length);
    }
    return _aims[level.name]!;
  }

  static final _aims = <String, List<int>>{};
}
