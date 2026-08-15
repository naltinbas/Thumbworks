import 'level.dart';
import 'rules.dart';

/// A year being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.loads, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [30, 30, 30, 30], 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, List<int> loads) => Play._(level, List.of(loads), 0, null);

  final Level level;

  /// The loads: Ash spring, Ash autumn, Birch spring, Birch autumn.
  final List<int> loads;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 20;

  Share get ashYear => Rules.year(0, loads[0], loads[1]);

  Share get birchYear => Rules.year(1, loads[2], loads[3]);

  bool get isDone => level.meets(loads[0], loads[1], loads[2], loads[3]);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps dial [i]: the load goes up a ten, and from fifty back to ten;
  /// on the equal-loads ask both healers' dials of that season move.
  Play tap(int i) {
    if (isOver || i < 0 || i > 3) return this;
    final next = List.of(loads);
    void turn(int k) => next[k] = next[k] >= 50 ? 10 : next[k] + 10;
    turn(i);
    if (level.equalLoads) turn(i < 2 ? i + 2 : i - 2);
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the first dial off the sweep's first
  /// setting; null when nothing lands.
  int? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final want = [aim.$1, aim.$2, aim.$3, aim.$4];
    for (var i = 0; i < 4; i++) {
      if (loads[i] != want[i]) return i;
    }
    return null;
  }

  /// The sweep's first setting for the ask, kept once found.
  static (int, int, int, int)? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, (int, int, int, int)?>{};
}
