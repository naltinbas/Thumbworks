import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.nails,
    required this.skip,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on seven nails and a skip of one, the rim: no ask
  /// is landed by that, and the checker says so.
  Play.of(this.level)
      : nails = 7,
        skip = 1,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.nails, this.skip)
      : moves = 0,
        before = null;

  final Level level;
  final int nails;
  final int skip;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never tries every skip of the six.
  static const gaveUpAt = 30;

  /// The strokes as they stand, walked.
  List<List<int>> get strokes => Rules.strokes(nails, skip);

  bool get isStar => Rules.isStar(nails, skip);

  /// Turns dial [which] (0 the nails, 1 the skip) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap. Fewer
  /// nails may pull the skip down to a nail short of the count.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var n = which == 0 ? nails + by.sign : nails;
    var k = which == 1 ? skip + by.sign : skip;
    if (n < Rules.fewest || n > Rules.most || k < 1 || k > nails - 1) return this;
    if (k > n - 1) k = n - 1;
    return Play._(
      level: level,
      nails: n,
      skip: k,
      moves: moves + 1,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(nails, skip);

  /// The skips tried at the hopeless ask's count of nails, this go and
  /// every go before it.
  Set<int> get skipsTriedAtSix {
    final tried = <int>{};
    for (Play? p = this; p != null; p = p.before) {
      if (p.nails == 6) tried.add(p.skip);
    }
    return tried;
  }

  /// A hopeless ask, admitted: the player has tried every skip of the six
  /// that could be a star, two, three and four, or has tapped [gaveUpAt]
  /// times.
  bool get gaveUp => !level.winnable && (skipsTriedAtSix.containsAll(const [2, 3, 4]) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the nails first, then the skip,
  /// each towards the aim; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (nails != aim.$1) return (0, (aim.$1 - nails).sign);
    if (skip != aim.$2) return (1, (aim.$2 - skip).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => aim.$1 == 0 ? '${aim.$2 > 0 ? 'Add' : 'Take away'} a nail.' : '${aim.$2 > 0 ? 'Widen' : 'Narrow'} the skip.';
}

/// Why the strokes are the shared factor: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Nails round a hoop, and a thread that goes from nail to nail '
      'skipping the same count each time. It comes home when the skips it has '
      'taken add up to a whole number of rounds, and the first time that '
      'happens is after the count of nails over the greatest factor the count '
      'and the skip share: share nothing and the thread touches every nail '
      'in one stroke; share a factor and it comes home early, and it takes '
      'as many strokes as the factor to touch them all. Six is two threes, '
      'and every skip that could make a star of six shares one of them, so '
      'the six-pointed star is two triangles and never one stroke.\n\n'
      'The game walks every thread nail by nail as well as taking the '
      'factor, and the two agree on every ring from three nails to twelve.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every ring of five to twelve nails '
      'and every skip, ${Rules.settings} settings, walked in full.';
}
