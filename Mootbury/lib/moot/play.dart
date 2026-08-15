import 'level.dart';
import 'rules.dart';

/// A moot being sized. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.seats, this.moves, this.before);

  /// The moot opens at five seats.
  factory Play.of(Level level) => Play._(level, 5, 0, null);

  /// A play stood at a size, for the mark and the tests.
  factory Play.standing(Level level, int seats) => Play._(level, seats, 0, null);

  final Level level;
  final int seats;

  /// Settings made, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  List<int> get pops => level.pops;
  List<(int, int)> get quotas => Rules.quotas(pops, seats);
  List<int> get hamilton => Rules.hamilton(pops, seats);
  List<int> get hamiltonNext => Rules.hamilton(pops, seats + 1);
  List<int> get jefferson => Rules.jeffersonDealt(pops, seats);
  List<int> get jeffersonNext => Rules.jeffersonDealt(pops, seats + 1);
  int? get loser => Rules.loser(pops, seats);

  bool get isDone => level.meets(seats);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sizes the moot by [by], within two and thirty.
  Play size(int by) {
    if (isOver) return this;
    final n = (seats + by).clamp(Rules.least, Rules.most);
    if (n == seats) return this;
    return Play._(level, n, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the step toward the first moot that
  /// lands, +5, +1, -1 or -5; null when nothing lands.
  int? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final gap = aim - seats;
    if (gap == 0) return null;
    if (gap >= 5) return 5;
    if (gap > 0) return 1;
    if (gap <= -5) return -5;
    return -1;
  }

  /// The sweep's first moot for the ask, kept once found.
  static int? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, int?>{};
}
