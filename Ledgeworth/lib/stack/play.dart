import 'level.dart';
import 'rules.dart';

/// A stack being leaned. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.offsets, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, List.filled(level.books, 0), 0, null);

  /// A play stood at a stack, for the mark and the tests.
  factory Play.standing(Level level, List<int> offsets) =>
      Play._(level, List.of(offsets), offsets.fold(0, (a, b) => a + b), null);

  final Level level;

  /// Each book's right edge past the edge below it, top first, in
  /// twenty-fourths.
  final List<int> offsets;

  /// Nudges, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless stack admits it.
  static const gaveUpAt = 26;

  int get overhang => Rules.overhang(offsets);

  int? get topples => Rules.topples(offsets);

  bool get stands => topples == null;

  List<int> get edges => Rules.edges(offsets);

  bool get isDone => stands && overhang >= level.asked;

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether book [i] can be nudged by [by], one twenty-fourth either way.
  bool touches(int i, int by) {
    if (isOver || i < 0 || i >= level.books || by == 0) return false;
    final v = offsets[i] + by;
    return v >= 0 && v <= Rules.grain;
  }

  /// Nudges book [i] right (by 1) or left (by -1) one twenty-fourth.
  Play tap(int i, int by) {
    if (!touches(i, by)) return this;
    final held = [for (var k = 0; k < offsets.length; k++) k == i ? offsets[k] + by : offsets[k]];
    return Play._(level, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('right', book) or ('left', book) for
  /// the first book off the harmonic stack; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = Rules.harmonic(level.books);
    for (var i = 0; i < offsets.length; i++) {
      if (offsets[i] < aim[i]) return ('right', i);
      if (offsets[i] > aim[i]) return ('left', i);
    }
    return null;
  }
}
