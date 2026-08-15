import 'level.dart';
import 'rules.dart';

/// A plaid being woven. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.rows, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, [...level.given, ...List.filled(level.size - level.given.length, 0)], 0, null);

  /// A play stood at a plaid, for the mark and the tests.
  factory Play.standing(Level level, List<int> rows) => Play._(level, level.rules, List.of(rows), 0, null);

  final Level level;
  final Rules rules;

  /// The rows, top down, as bits.
  final List<int> rows;

  /// Flips, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless plaid admits it.
  static const gaveUpAt = 30;

  bool isGiven(int r) => r < level.given.length;

  bool dark(int r, int c) => Rules.dark(rows[r], c);

  List<(int, int)> get uneven => rules.uneven(rows);

  int get pairs => rows.length * (rows.length - 1) ~/ 2;

  bool get isDone => rules.lands(rows);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Flips the square at row [r], column [c], if the row is not given.
  Play flip(int r, int c) {
    if (isOver || r < 0 || r >= rows.length || c < 0 || c >= level.size || isGiven(r)) return this;
    final next = [for (var i = 0; i < rows.length; i++) i == r ? rows[i] ^ (1 << c) : rows[i]];
    return Play._(level, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the first square off the walk's first
  /// filling, as (row, column); null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var r = level.given.length; r < rows.length; r++) {
      for (var c = 0; c < level.size; c++) {
        if (Rules.dark(rows[r], c) != Rules.dark(aim[r], c)) return (r, c);
      }
    }
    return null;
  }

  /// The walk's first filling of the plaid as given, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, first) = level.rules.walk(level.given);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
