import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the point stood on, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.at,
    required this.moves,
    required this.before,
  });

  /// Every ask opens standing at 3, 3 and 6: no ask is landed by that,
  /// and the checker says so.
  Play.of(this.level)
      : at = (3, 3, 6),
        moves = 0,
        before = null;

  /// A play stood at a point, for the mark and the tests.
  Play.standing(this.level, this.at)
      : moves = 0,
        before = null;

  final Level level;

  /// The point stood on, as rungs (floor, right slope, left slope).
  final (int, int, int) at;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 20;

  int get sum => Rules.rungsAdded(at);
  (int, int, int) get areas => Rules.areas(at);

  /// Taps a point of the green: the walker moves there.
  Play tap((int, int, int) p) {
    if (isOver || p.$1 < 0 || p.$2 < 0 || p.$3 < 0 || p.$1 + p.$2 + p.$3 != Rules.side || p == at) return this;
    return Play._(level: level, at: p, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(at);

  /// A hopeless ask, admitted: the walker has stood at a corner, where
  /// one distance is the whole height and the others nought, and the sum
  /// is twelve still; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && ([at.$1, at.$2, at.$3].contains(Rules.side) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the aim, or null.
  (int, int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver || at == aim) return null;
    return aim;
  }

  static String pointed((int, int, int) aim) => 'Stand on the ringed point, ${Rules.told(aim)}.';
}

/// Why the height, always: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Stand anywhere on an equilateral green and measure your distance to '
      'each of the three sides: the three add up to the height, wherever you '
      'stand. Viviani saw why in the 1600s: the three triangles you make with '
      'the sides fill the green exactly, each is half a side times a distance, '
      'and the sides are all alike, so the distances add to twice the area '
      'over the side, which is the height.\n\n'
      'The game walks every point of the lattice inside the green of side '
      'twelve, ${Rules.count} of them, reads the rungs straight off the '
      'lattice, and works the three triangles as whole numbers of cells: they '
      'fill the green on every point, and each is the rung\'s share of it, and '
      'the rungs add to twelve on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every point of the green, tried in '
      'full.';
}
