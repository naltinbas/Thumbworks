import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three sides, the taps taken to set them, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.a,
    required this.b,
    required this.c,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on 3, 4, 6, an area of a hair over five and a third:
  /// no ask is landed by that, and the checker says so.
  Play.of(this.level)
      : a = 3,
        b = 4,
        c = 6,
        moves = 0,
        before = null;

  /// A play stood at three sides, for the mark and the tests.
  Play.standing(this.level, this.a, this.b, this.c)
      : moves = 0,
        before = null;

  final Level level;
  final int a, b, c;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if three odd sides
  /// are never set closing.
  static const gaveUpAt = 30;

  bool get closes => Rules.closes(a, b, c);
  int? get wholeArea => Rules.wholeArea(a, b, c);
  double get area => Rules.area(a, b, c);
  int get sixteenAreaSquared => Rules.sixteenAreaSquared(a, b, c);

  List<int> get sides => [a, b, c];

  /// Turns dial [which] (0, 1, 2 for the three sides) by [by]; a dial at
  /// its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final s = sides;
    s[which] = s[which] + by.sign;
    if (s[which] < 1 || s[which] > Rules.most) return this;
    return Play._(level: level, a: s[0], b: s[1], c: s[2], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(a, b, c);

  /// A hopeless ask, admitted: three odd sides that close are set, and
  /// the area is not whole, as it never is; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (closes && Rules.allOdd(a, b, c) && wholeArea == null || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the first side off the aim
  /// first; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = [aim.$1, aim.$2, aim.$3];
    for (var i = 0; i < 3; i++) {
      if (sides[i] != want[i]) return (i, (want[i] - sides[i]).sign);
    }
    return null;
  }

  static String pointed((int, int) aim) => '${aim.$2 > 0 ? 'Lengthen' : 'Shorten'} the ${const ['first', 'second', 'third'][aim.$1]} side.';
}

/// Why the whole areas, and why the odds never: the words behind the
/// Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Heron of Alexandria wrote the area of a triangle in its sides alone: '
      'sixteen times the area squared is the perimeter times the perimeter '
      'less twice each side in turn. So a triangle with whole sides has an '
      'area that is whole, or a square root that is not, and only ten to '
      'fifteen come whole: 3-4-5, 5-5-6, 5-5-8, 5-12-13, 6-8-10, 4-13-15, '
      '9-12-15, 10-10-12, 10-13-13 and 13-14-15. Three odd sides never do: '
      'the perimeter and the perimeter less twice each side are then all odd, '
      'and an odd product is never sixteen times anything.\n\n'
      'The game works the area two ways on every one of the 372 triangles to '
      'fifteen, by Heron and by the height, the foot of the perpendicular '
      'found by Pythagoras in whole numbers, and the two agree on every one; '
      'every whole area found is a multiple of six, and every whole-area '
      'triangle has an even side.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every triangle with whole sides '
      'to fifteen, 372 of them, tried in full.';
}
