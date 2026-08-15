import 'level.dart';
import 'rules.dart';

/// A green being laid out. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.at, this.held, this.moves, this.before, this.refused);

  factory Play.of(Level level) => Play._(level, List.of(level.start), null, 0, null, false);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Level level, List<(int, int)> at) => Play._(level, List.of(at), null, 0, null, false);

  final Level level;

  /// Where each hamlet stands.
  final List<(int, int)> at;

  /// The hamlet held, to be moved, or null.
  final int? held;

  /// Moves made, counted.
  final int moves;

  final Play? before;

  /// Whether the last tap tried to move a hamlet onto another.
  final bool refused;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  List<(int, int)> get lanes => level.lanes;

  List<(int, int)> get crossings => Rules.crossings(lanes, at);
  List<(int, int)> get throughs => Rules.throughs(lanes, at);

  bool get isDone => level.meets(at);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The hamlet standing at [point], or null.
  int? hamletAt((int, int) point) {
    final i = at.indexOf(point);
    return i < 0 ? null : i;
  }

  /// Taps a hamlet: held, or let go if held already.
  Play hold(int h) {
    if (isOver || h < 0 || h >= level.hamlets) return this;
    return Play._(level, at, held == h ? null : h, moves, this, false);
  }

  /// Taps a grid point: the held hamlet moves there, if the point is bare.
  Play move((int, int) point) {
    if (isOver) return this;
    final h = held;
    if (h == null) return this;
    if (point.$1 < 0 || point.$2 < 0 || point.$1 >= level.size || point.$2 >= level.size) return this;
    if (at.contains(point)) return Play._(level, at, held, moves, this, true);
    final next = List.of(at)..[h] = point;
    return Play._(level, next, null, moves + 1, this, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: (hamlet, point), the next hamlet to
  /// stand where the sweep's first clear placing has it; a hamlet in the
  /// way is moved to the first bare point first. Null when nothing lands.
  (int, (int, int))? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var h = 0; h < level.hamlets; h++) {
      if (at[h] == aim[h]) continue;
      final blocker = hamletAt(aim[h]);
      if (blocker != null) {
        // Move the blocker to its own place if bare, else to the first
        // bare point.
        if (hamletAt(aim[blocker]) == null) return (blocker, aim[blocker]);
        for (var y = 0; y < level.size; y++) {
          for (var x = 0; x < level.size; x++) {
            if (hamletAt((x, y)) == null) return (blocker, (x, y));
          }
        }
      }
      return (h, aim[h]);
    }
    return null;
  }

  /// The sweep's first clear placing for the ask, kept once found.
  static List<(int, int)>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, _, first) = Rules.sweep(level.hamlets, level.lanes, level.size, atMost: 1);
      _aims[level.name] = first;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<(int, int)>?>{};
}
