import 'level.dart';
import 'rules.dart';

/// A set of calls being whistled. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.level, this.marks, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [], 0, null);

  /// A play stood at a marking, for the mark and the tests.
  factory Play.standing(Level level, List<int> marks) => Play._(level, List.of(marks), marks.length, null);

  final Level level;

  /// The nodes marked as whistles, in the order they were tapped.
  final List<int> marks;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless calls admit it.
  static const gaveUpAt = 13;

  Rules get rules => Level.rules;

  List<(int, int)> get clashes => rules.clashes(marks);

  bool isMarked(int k) => marks.contains(k);

  bool shadowed(int k) => rules.shadowed(k, marks);

  /// The shares the marks take of the whole, added whether or not they fit.
  int get share => rules.share(marks.map(Rules.notesOf));

  /// Which call node [k] whistles, or null: the i-th mark of a length, in
  /// tap order, is the i-th call of that length.
  int? callOf(int k) {
    if (!isMarked(k)) return null;
    final l = Rules.notesOf(k);
    var seen = 0;
    for (final m in marks) {
      if (m == k) break;
      if (Rules.notesOf(m) == l) seen++;
    }
    var i = 0;
    for (var c = 0; c < level.calls.length; c++) {
      if (level.calls[c].$2 != l) continue;
      if (i == seen) return c;
      i++;
    }
    return null;
  }

  /// The node whistling call [c], or null.
  int? nodeOf(int c) {
    for (final m in marks) {
      if (callOf(m) == c) return m;
    }
    return null;
  }

  /// Marks that whistle a call, as against those over the count asked.
  int get whistled => marks.where((m) => callOf(m) != null).length;

  /// Marks over the count asked at their length.
  int get over => marks.length - whistled;

  bool get isDone => rules.lands(marks, level.lengths);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int k) => !isOver && k >= 2 && k < (1 << (rules.depth + 1));

  /// Taps a node: marks it as a whistle, or lifts the mark.
  Play tap(int k) {
    if (!touches(k)) return this;
    final next = isMarked(k) ? [for (final m in marks) if (m != k) m] : [...marks, k];
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', node) for a mark off the
  /// shepherd's marking, else ('mark', node) for the first of the
  /// shepherd's not marked; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final m in marks) {
      if (!aim.contains(m)) return ('lift', m);
    }
    for (final k in aim) {
      if (!isMarked(k)) return ('mark', k);
    }
    return null;
  }

  /// The shepherd's marking, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Level.rules.byShepherd(level.lengths);
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
