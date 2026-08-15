import 'level.dart';
import 'rules.dart';

/// A board being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.bishops, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, Rules(level.side), List.of(level.given), 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, List<Square> bishops) =>
      Play._(level, Rules(level.side), List.of(bishops), bishops.length - level.given.length, null);

  final Level level;
  final Rules rules;

  /// The bishops standing, the given ones first, then in the order set.
  final List<Square> bishops;

  /// Bishops set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless board admits it.
  static const gaveUpAt = 13;

  List<(int, int)> get clashes => Rules.clashes(bishops);

  bool get peaceful => clashes.isEmpty;

  bool get full => bishops.length == level.bishops;

  int get risingUsed => rules.risingUsed(bishops);

  bool get isDone => full && peaceful;

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool isGiven(Square s) => level.given.contains(s);

  bool touches(Square s) =>
      !isOver && s.$1 >= 0 && s.$1 < level.side && s.$2 >= 0 && s.$2 < level.side &&
      !isGiven(s) && (bishops.contains(s) || !full);

  /// Taps a square: sets a bishop, or lifts the one there.
  Play tap(Square s) {
    if (!touches(s)) return this;
    final held = bishops.contains(s) ? [for (final b in bishops) if (b != s) b] : [...bishops, s];
    return Play._(level, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', square) for a bishop off the
  /// aim, or ('set', square) for the next; null when nothing lands.
  (String, Square)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final b in bishops) {
      if (!aim.contains(b)) return ('lift', b);
    }
    for (final s in aim) {
      if (!bishops.contains(s)) return ('set', s);
    }
    return null;
  }

  /// The sweep's first peaceful setting holding the given, kept once
  /// found.
  static List<Square>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      List<Square>? found;
      Rules(level.side).settings(level.bishops, (b) {
        if (found == null && level.given.every(b.contains) && Rules.peaceful(b)) found = List.of(b);
      });
      _aims[level.name] = found;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<Square>?>{};
}
