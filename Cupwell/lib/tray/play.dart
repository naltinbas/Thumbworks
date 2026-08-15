import 'level.dart';
import 'rules.dart';

/// A tray being righted. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.tray, this.marked, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, Rules(level.cups, level.each), level.down, const {}, 0, null);

  /// A play stood at a tray, for the mark and the tests.
  factory Play.standing(Level level, int tray, int moves) =>
      Play._(level, Rules(level.cups, level.each), tray, const {}, moves, null);

  final Level level;
  final Rules rules;

  /// The cups down, as bits.
  final int tray;

  /// The cups picked for the turn under way.
  final Set<int> marked;

  /// Turns made, counted.
  final int moves;

  final Play? before;

  bool isDown(int cup) => (tray >> cup) & 1 == 1;

  int get downCount => Rules.downCount(tray);

  bool get isDone => tray == rules.allUp;

  /// The turns spent and the tray not righted: over, not landed.
  bool get missed => moves == level.turns && !isDone;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  bool touches(int cup) => !isOver && cup >= 0 && cup < level.cups;

  /// Taps a cup: marks it for the turn, or unmarks it; when as many are
  /// marked as turn over at a time, they all turn.
  Play tap(int cup) {
    if (!touches(cup)) return this;
    if (marked.contains(cup)) {
      return Play._(level, rules, tray, {...marked}..remove(cup), moves, before);
    }
    final next = {...marked, cup};
    if (next.length < level.each) return Play._(level, rules, tray, next, moves, before);
    var set = 0;
    for (final c in next) {
      set |= 1 << c;
    }
    return Play._(level, rules, Rules.turned(tray, set), const {}, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('unmark', cup) for a cup marked off
  /// the nearing turn, or ('mark', cup) for the next cup of it; null when
  /// nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    // Only within the count: the turns left must be the fewest from here.
    final fewest = rules.fewest(tray);
    if (fewest == null || fewest != level.turns - moves) return null;
    final set = rules.nextTurn(tray);
    if (set == null) return null;
    for (final c in marked) {
      if ((set >> c) & 1 == 0) return ('unmark', c);
    }
    for (var c = 0; c < level.cups; c++) {
      if ((set >> c) & 1 == 1 && !marked.contains(c)) return ('mark', c);
    }
    return null;
  }
}
