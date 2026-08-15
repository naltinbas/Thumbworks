import 'level.dart';
import 'rules.dart';

/// A lane being marked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.marks, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, Rules(level.count), const [], 0, null);

  /// A play stood at a marking, for the mark and the tests.
  factory Play.standing(Level level, List<int> marks) =>
      Play._(level, Rules(level.count), List.of(marks), marks.length, null);

  final Level level;
  final Rules rules;

  /// The milestones marked, in the order set: the two ends of the run.
  final List<int> marks;

  /// Marks set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless lane admits it.
  static const gaveUpAt = 12;

  bool get full => marks.length == 2;

  /// The run between the marks, when both stand.
  Run? get run {
    if (!full) return null;
    final a = marks[0] < marks[1] ? marks[0] : marks[1];
    final b = marks[0] < marks[1] ? marks[1] : marks[0];
    return (a, b);
  }

  int? get sum => run == null ? null : Rules.sum(run!);

  bool get isDone => run != null && rules.lands(run!);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int stone) =>
      !isOver && stone >= 1 && stone <= level.count && (marks.contains(stone) || !full);

  /// Taps a milestone: marks it, or lifts the mark there.
  Play tap(int stone) {
    if (!touches(stone)) return this;
    final held = marks.contains(stone) ? [for (final m in marks) if (m != stone) m] : [...marks, stone];
    return Play._(level, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', stone) for a mark off the
  /// aim, or ('set', stone) for the next; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final want = [aim.$1, aim.$2];
    for (final m in marks) {
      if (!want.contains(m)) return ('lift', m);
    }
    for (final s in want) {
      if (!marks.contains(s)) return ('set', s);
    }
    return null;
  }

  /// The sweep's first landing run, kept once found.
  static Run? aimFor(Level level) {
    if (!_aims.containsKey(level.count)) {
      final landings = Rules(level.count).landings();
      _aims[level.count] = landings.isEmpty ? null : landings.first;
    }
    return _aims[level.count];
  }

  static final _aims = <int, Run?>{};
}
