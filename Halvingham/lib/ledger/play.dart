import 'level.dart';
import 'rules.dart';

/// A ledger being kept. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.kept, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [], 0, null);

  /// A play stood at a keeping, for the mark and the tests.
  factory Play.standing(Level level, List<int> kept) => Play._(level, level.rules, List.of(kept), kept.length, null);

  final Level level;
  final Rules rules;

  /// The rows kept, in the order kept.
  final List<int> kept;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ledger admits it.
  static const gaveUpAt = 12;

  List<(int, int)> get rows => rules.rows;

  bool isKept(int i) => kept.contains(i);

  int get sum => rules.sumOf(kept);

  bool get isDone => rules.lands(kept, exactly: level.exactly);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps a row: keeps it, or lets it go.
  Play tap(int i) {
    if (isOver || i < 0 || i >= rows.length) return this;
    final next = isKept(i) ? [for (final k in kept) if (k != i) k] : [...kept, i];
    return Play._(level, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('let', row) for a kept row off the
  /// rule, else ('keep', row) for the first odd row not kept; null when
  /// nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final odd = rules.oddRows;
    for (final k in kept) {
      if (!odd.contains(k)) return ('let', k);
    }
    for (final i in odd) {
      if (!isKept(i)) return ('keep', i);
    }
    return null;
  }
}
