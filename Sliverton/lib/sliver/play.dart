import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three marks on their dials, the taps taken,
/// the settings where the cuts met, and the go before, so a tap can be
/// taken back.
class Play {
  const Play._({
    required this.level,
    required this.marks,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : marks = const [3, 3, 3],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.marks)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Where the three marks stand, in twelfths: on BC, on CA, on AB.
  final List<int> marks;

  /// The taps taken.
  final int moves;

  /// The settings tried whose three cuts met at a point.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never makes the cuts meet.
  static const gaveUpAt = 20;

  /// The meetings a hopeless ask lets the player find before the sham
  /// admits it.
  static const enough = 3;

  static const names = ['D', 'E', 'F'];

  /// The sliver's share of the field, by its corners.
  Frac get share => Rules.shareByCorners(marks);

  /// The share by Routh's rule, the second voice.
  Frac get shareByRouth => Rules.shareByRouth(marks);

  /// The three corners of the sliver.
  List<Spot>? get sliver => Rules.sliver(marks);

  bool get cutsMeet => Rules.cutsMeet(marks);

  bool get gone => Rules.slivergone(marks);

  /// The three ratios the marks divide the sides in.
  List<Frac> get ratios => [Rules.ratioX(marks[0]), Rules.ratioY(marks[1]), Rules.ratioZ(marks[2])];

  /// The ratios multiplied: one exactly when the cuts meet.
  Frac get ratioProduct => ratios[0] * ratios[1] * ratios[2];

  /// Steps the mark [which], 0, 1 or 2, along its side.
  Play step(int which, int by) {
    if (isOver || which < 0 || which > 2 || by == 0) return this;
    final to = marks[which] + by;
    if (to < Rules.least || to > Rules.most) return this;
    final next = List.of(marks)..[which] = to;
    final nowSeen = Rules.cutsMeet(next) ? {...seen, next.join(',')} : seen;
    return Play._(level: level, marks: next, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(marks);

  /// A hopeless ask, admitted: [enough] settings found where the cuts
  /// met, each with the sliver gone, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && cutsMeet || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (which, by), the first mark off the aim
  /// stepped towards it; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < 3; i++) {
      if (marks[i] != aim[i]) return (i, aim[i] > marks[i] ? 1 : -1);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Step mark ${names[aim.$1]} ${aim.$2 > 0 ? 'on' : 'back'}.';
}

/// Why the sliver goes only when the cuts meet: the words behind the
/// Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A triangle field, each side marked off in twelfths, and a cut from '
      'each corner to a mark on the far side. The three cuts leave a sliver '
      'in the middle, and how much of the field it takes depends on the three '
      'ratios the marks divide the sides in: x for BD over DC, y for CE over '
      'EA, z for AF over FB. Routh\'s rule, published in 1891, is that the '
      'sliver\'s share is the square of xyz less one, over '
      '(xy + x + 1)(yz + y + 1)(zx + z + 1). Cut to the two-thirds mark on '
      'every side and the share is a seventh, the one-seventh triangle. The '
      'sliver goes to nothing exactly when xyz is one, and that is Ceva\'s '
      'condition of 1678 for the three cuts to meet at a point: if the sliver '
      'has no area its three corners are one point, and that point lies on '
      'all three cuts.\n\n'
      'The game takes every setting of the three marks, 1,331 of them, and '
      'measures the sliver twice, once by crossing the cuts in exact '
      'fractions and taking the area off its corners, and once by Routh\'s '
      'rule with no crossing in sight; the two agree on all 1,331, the sliver '
      'is gone on 31 settings, and the cuts meet on the same 31.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every setting of the marks, cut '
      'in full.';
}
