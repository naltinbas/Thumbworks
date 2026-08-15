import 'level.dart';
import 'rules.dart';

/// A stall being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.doors, this.opened, this.switching, this.moves, this.before);

  /// The stall opens with three doors, one opened, and the player staying.
  factory Play.of(Level level) => Play._(level, 3, 1, false, 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, int doors, int opened, bool switching) => Play._(level, doors, opened, switching, 0, null);

  final Level level;
  final int doors;
  final int opened;
  final bool switching;

  /// Settings made, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  (int, int) get chance => Rules.byFormula(doors, opened, switching);
  (int, int) get stayChance => Rules.byFormula(doors, opened, false);
  (int, int) get switchChance => Rules.byFormula(doors, opened, true);

  bool get isDone => level.meets(doors, opened, switching);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Adds [by] doors, within three and ten; the doors opened are kept
  /// within one and n - 2.
  Play moreDoors(int by) {
    if (isOver) return this;
    final n = (doors + by).clamp(Rules.doorsLeast, Rules.doorsMost);
    if (n == doors) return this;
    final k = opened.clamp(1, n - 2);
    return Play._(level, n, k, switching, moves + 1, this);
  }

  /// Opens [by] more doors, within one and n - 2.
  Play moreOpened(int by) {
    if (isOver) return this;
    final k = (opened + by).clamp(1, doors - 2);
    if (k == opened) return this;
    return Play._(level, doors, k, switching, moves + 1, this);
  }

  /// Turns the policy round.
  Play togglePolicy() {
    if (isOver) return this;
    return Play._(level, doors, opened, !switching, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: 'doors+', 'doors-', 'opened+',
  /// 'opened-' or 'policy'; null when nothing lands.
  String? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final (n, k, sw) = aim;
    if (doors != n) return doors < n ? 'doors+' : 'doors-';
    if (opened != k) return opened < k ? 'opened+' : 'opened-';
    if (switching != sw) return 'policy';
    return null;
  }

  /// The sweep's first setting for the ask, kept once found.
  static (int, int, bool)? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, (int, int, bool)?>{};
}
