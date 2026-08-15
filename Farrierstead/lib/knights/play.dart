import 'level.dart';
import 'rules.dart';

/// A board being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.knights, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [], 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, List<int> knights) =>
      Play._(level, level.rules, List.of(knights), knights.length, null);

  final Level level;
  final Rules rules;

  /// The squares with knights, in the order set.
  final List<int> knights;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless board admits it.
  static const gaveUpAt = 13;

  List<(int, int)> get clashes => rules.clashes(knights);

  bool has(int c) => knights.contains(c);

  bool get isDone => rules.lands(knights, level.knights);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int c) => !isOver && c >= 0 && c < rules.squares;

  /// Taps a square: sets a knight, or lifts the one there.
  Play tap(int c) {
    if (!touches(c)) return this;
    final next = has(c) ? [for (final k in knights) if (k != c) k] : [...knights, c];
    return Play._(level, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', square) for a knight off the
  /// one-colour setting, else ('set', square) for the first square of it
  /// with no knight; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    for (final k in knights) {
      if (!aim.contains(k)) return ('lift', k);
    }
    for (final c in aim) {
      if (!has(c)) return ('set', c);
    }
    return null;
  }

  /// The one-colour setting, kept once found: the corners' colour, or
  /// its first knights when the board asks for fewer.
  static List<int> aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final colour = level.rules.oneColour;
      _aims[level.name] = colour.sublist(0, level.knights < colour.length ? level.knights : colour.length);
    }
    return _aims[level.name]!;
  }

  static final _aims = <String, List<int>>{};
}
