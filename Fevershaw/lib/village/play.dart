import 'level.dart';
import 'rules.dart';

/// A village being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.prevalence, this.catchAt, this.alarmAt, this.moves, this.before);

  /// The village opens with the fever one in two, the test catching nine
  /// in ten and flagging the well one in ten.
  factory Play.of(Level level) => Play._(level, 0, 0, 0, 0, null);

  /// A play stood at a setting, for the mark and the tests.
  factory Play.standing(Level level, int prevalence, int catchAt, int alarmAt) => Play._(level, prevalence, catchAt, alarmAt, 0, null);

  final Level level;

  /// Indexes into the sham's lists.
  final int prevalence;
  final int catchAt;
  final int alarmAt;

  /// Settings made, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  int get oneIn => Rules.prevalences[prevalence];
  (int, int) get catchRate => Rules.catches[catchAt];
  (int, int) get alarm => Rules.alarms[alarmAt];

  (int, int) get share => Rules.byChances(oneIn, catchRate, alarm);
  (int, int, int, int) get counted => Rules.counted(oneIn, catchRate, alarm);

  bool get isDone => level.meets(oneIn, catchRate, alarm);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets dial 0, the fever, 1, the catch, or 2, the alarm, to [at].
  Play set(int dial, int at) {
    if (isOver) return this;
    final most = dial == 0 ? Rules.prevalences.length : dial == 1 ? Rules.catches.length : Rules.alarms.length;
    if (at < 0 || at >= most) return this;
    final now = dial == 0 ? prevalence : dial == 1 ? catchAt : alarmAt;
    if (at == now) return this;
    return Play._(level, dial == 0 ? at : prevalence, dial == 1 ? at : catchAt, dial == 2 ? at : alarmAt, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: (dial, index), the first dial off the
  /// sweep's first setting; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final (p, c, a) = aim;
    final pi = Rules.prevalences.indexOf(p), ci = Rules.catches.indexOf(c), ai = Rules.alarms.indexOf(a);
    if (prevalence != pi) return (0, pi);
    if (catchAt != ci) return (1, ci);
    if (alarmAt != ai) return (2, ai);
    return null;
  }

  /// The sweep's first setting for the ask, kept once found.
  static (int, (int, int), (int, int))? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, (int, (int, int), (int, int))?>{};
}
