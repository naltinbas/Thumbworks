import 'level.dart';
import 'rules.dart';

/// A supper being seated. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.tables, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, List.filled(level.guests, -1), 0, null);

  /// A play stood at a seating, for the mark and the tests.
  factory Play.standing(Level level, List<int> tables) =>
      Play._(level, level.rules, List.of(tables), tables.where((t) => t >= 0).length, null);

  final Level level;
  final Rules rules;

  /// Each guest's table: left, right, or -1 standing.
  final List<int> tables;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless supper admits it.
  static const gaveUpAt = 13;

  List<Quarrel> get clashes => rules.clashes(tables);

  int get seatedCount => tables.where((t) => t >= 0).length;

  bool get seated => rules.seated(tables);

  bool get isDone => rules.lands(tables);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int g) => !isOver && g >= 0 && g < level.guests;

  /// Taps a guest: standing to left, left to right, right to standing.
  Play tap(int g) {
    if (!touches(g)) return this;
    final next = tables[g] == -1 ? Rules.left : tables[g] == Rules.left ? Rules.right : -1;
    return Play._(level, rules, [for (var i = 0; i < tables.length; i++) i == g ? next : tables[i]], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('left', guest) or ('right', guest) for
  /// the first guest off the walk's seating; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var g = 0; g < level.guests; g++) {
      if (tables[g] != aim[g]) return (aim[g] == Rules.left ? 'left' : 'right', g);
    }
    return null;
  }

  /// The walk's seating, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = level.rules.byWalking();
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
