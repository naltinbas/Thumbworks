import 'level.dart';
import 'rules.dart';

/// A comb being filled. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.values, this.held, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, List.of(level.given), null, 0, null);

  /// A play stood at a filling, for the mark and the tests.
  factory Play.standing(Level level, List<int> values) => Play._(level, level.rules, List.of(values), null,
      [for (var c = 0; c < Rules.cells; c++) if (level.given[c] == 0 && values[c] != 0) c].length, null);

  final Level level;
  final Rules rules;

  /// The number in each cell, nought for empty.
  final List<int> values;

  /// The cell picked to take a number, if any.
  final int? held;

  /// Numbers set, counted; picking and clearing are free.
  final int moves;

  final Play? before;

  /// The line past which the hopeless comb admits it, if filling it
  /// has not shown it first.
  static const gaveUpAt = 40;

  bool isGiven(int c) => level.given[c] != 0;

  bool get isFull => values.every((v) => v != 0);

  int get filled => values.where((v) => v != 0).length;

  /// The numbers not yet in the comb.
  List<int> get left => [for (var v = 1; v <= Rules.cells; v++) if (!values.contains(v)) v];

  /// Lines complete and summing right.
  List<int> get rightLines => [
        for (var i = 0; i < Rules.lines.length; i++)
          if (rules.lineStanding(values, i) == (rules.sum, 0)) i,
      ];

  /// Lines complete and summing wrong.
  List<int> get wrongLines => [
        for (var i = 0; i < Rules.lines.length; i++)
          if (rules.lineStanding(values, i).$2 == 0 && rules.lineStanding(values, i).$1 != rules.sum) i,
      ];

  bool get isDone => rules.magic(values);

  bool get gaveUp => !level.winnable && !isDone && (isFull || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Taps a cell: picks an empty one to take a number, clears one the
  /// player filled, and leaves a given one be.
  Play tap(int c) {
    if (isOver || c < 0 || c >= Rules.cells || isGiven(c)) return this;
    if (values[c] != 0) {
      final next = [for (var i = 0; i < Rules.cells; i++) i == c ? 0 : values[i]];
      return Play._(level, rules, next, null, moves, this);
    }
    return Play._(level, rules, values, held == c ? null : c, moves, this);
  }

  /// Puts number [v] in the picked cell, if it is not in the comb already.
  Play put(int v) {
    final c = held;
    if (c == null || isOver || v < 1 || v > Rules.cells || values.contains(v)) return this;
    final next = [for (var i = 0; i < Rules.cells; i++) i == c ? v : values[i]];
    return Play._(level, rules, next, null, moves + 1, this);
  }

  /// Undoes the last number set, or the last pick or clearing.
  Play get back => before ?? this;

  /// What the show-me points at: ('clear', cell, 0) for a cell filled off
  /// the walk's filling, else ('set', cell, number) for the first empty
  /// cell in the walk's order; null when nothing lands.
  (String, int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var c = 0; c < Rules.cells; c++) {
      if (!isGiven(c) && values[c] != 0 && values[c] != aim[c]) return ('clear', c, 0);
    }
    for (final c in Rules.order) {
      if (values[c] == 0) return ('set', c, aim[c]);
    }
    return null;
  }

  /// The walk's first filling of the comb as given, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final found = level.rules.fillings(level.given, most: 1);
      _aims[level.name] = found.isEmpty ? null : found.first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
