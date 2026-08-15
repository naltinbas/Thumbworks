import 'level.dart';
import 'rules.dart';

/// A stall being played. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.picked, this.tried, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, null, const [], 0, null);

  /// A play stood at a pick, for the mark and the tests.
  factory Play.standing(Level level, int picked) => Play._(level, picked, [picked], 1, null);

  final Level level;

  /// The die picked, if any.
  final int? picked;

  /// The dice tried, in order.
  final List<int> tried;

  /// Picks made, counted.
  final int moves;

  final Play? before;

  bool get isDone => picked != null && level.lands(picked!);

  /// Every choice tried and none lands: the hopeless stall admits it.
  bool get gaveUp => !level.winnable && level.choices.every(tried.contains);

  bool get isOver => isDone || gaveUp;

  /// The house's faces, or the faces of the die the pick is held against
  /// on the champion's stall: the first other die it fails to beat, or
  /// the last other.
  int? get against {
    if (level.house >= 0) return level.house;
    final p = picked;
    if (p == null) return null;
    for (var y = 0; y < 4; y++) {
      if (y != p && !Rules.beats(Rules.dice[p], Rules.dice[y])) return y;
    }
    return null;
  }

  /// The rolls the pick wins against [against], of thirty-six.
  int get winsNow => picked == null || against == null ? 0 : Rules.wins(Rules.dice[picked!], Rules.dice[against!]);

  /// Picks die [x].
  Play pick(int x) {
    if (isOver || !level.choices.contains(x)) return this;
    return Play._(level, x, tried.contains(x) ? tried : [...tried, x], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the die that lands; null when nothing
  /// lands.
  int? get next {
    if (isOver || !level.winnable) return null;
    for (final x in level.choices) {
      if (level.lands(x)) return x;
    }
    return null;
  }
}
