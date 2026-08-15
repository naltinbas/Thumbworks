import 'level.dart';
import 'rules.dart';

/// A table being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.along, this.up, this.moves, this.before);

  /// The table opens at three by two.
  factory Play.of(Level level) => Play._(level, 3, 2, 0, null);

  /// A play stood at a table, for the mark and the tests.
  factory Play.standing(Level level, int along, int up) => Play._(level, along, up, 0, null);

  final Level level;
  final int along;
  final int up;

  /// Settings made, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  /// The path rolled step by step: corners, bounces, steps.
  (List<(int, int)>, int, int) get rolled => Rules.roll(along, up);

  List<(int, int)> get corners => rolled.$1;
  int get bounces => rolled.$2;
  int get steps => rolled.$3;
  (int, int) get pocket => corners.last;
  String get pocketName => Rules.pocketName(along, up, pocket);

  bool get isDone => level.meets(along, up);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Sets the side along by [by], within two and twelve.
  Play moreAlong(int by) {
    if (isOver) return this;
    final n = (along + by).clamp(Rules.least, Rules.most);
    if (n == along) return this;
    return Play._(level, n, up, moves + 1, this);
  }

  /// Sets the side up by [by], within two and twelve.
  Play moreUp(int by) {
    if (isOver) return this;
    final n = (up + by).clamp(Rules.least, Rules.most);
    if (n == up) return this;
    return Play._(level, along, n, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: 'along+', 'along-', 'up+' or 'up-';
  /// null when nothing lands.
  String? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    final (p, q) = aim;
    if (along != p) return along < p ? 'along+' : 'along-';
    if (up != q) return up < q ? 'up+' : 'up-';
    return null;
  }

  /// The sweep's first table for the ask, kept once found.
  static (int, int)? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, (int, int)?>{};
}
