import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the share and the steps set, the taps taken to set
/// them, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.shareIndex,
    required this.steps,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : shareIndex = 0,
        steps = 1,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.shareIndex, this.steps)
      : moves = 0,
        before = null;

  final Level level;

  /// Which share of [Rules.shares] each step covers.
  final int shareIndex;

  /// How many steps are taken.
  final int steps;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets to twenty steps.
  static const gaveUpAt = 20;

  /// The steps at which the hopeless ask is admitted: the runner is as
  /// near as the sham cares to draw.
  static const farEnough = 20;

  Frac get share => Rules.shares[shareIndex];

  /// The steps as lengths.
  List<Frac> get lengths => Rules.steps(share, steps);

  /// How far the runner has come, by adding the steps, the first voice.
  Frac get covered => Rules.coveredBySum(share, steps);

  /// How far, by the form, the second voice.
  Frac get coveredByForm => Rules.coveredByForm(share, steps);

  /// What is left to the wall.
  Frac get left => Rules.left(share, steps);

  /// Turns dial [which] (0 the share, 1 the steps) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var i = shareIndex, n = steps;
    if (which == 0) {
      i += by.sign;
      if (i < 0 || i >= Rules.shares.length) return this;
    } else {
      n += by.sign;
      if (n < 1 || n > Rules.most) return this;
    }
    return Play._(level: level, shareIndex: i, steps: n, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(share, steps);

  /// A hopeless ask, admitted: twenty steps are taken, or [gaveUpAt]
  /// taps are gone.
  bool get gaveUp => !level.winnable && (steps >= farEnough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the share first, then the
  /// steps, each towards the aim; null when there is nothing to point
  /// at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final wantIndex = Rules.shares.indexOf(aim.$1);
    if (shareIndex != wantIndex) return (0, (wantIndex - shareIndex).sign);
    if (steps != aim.$2) return (1, (aim.$2 - steps).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => aim.$1 == 0 ? 'Turn the share ${aim.$2 > 0 ? 'up' : 'down'}.' : '${aim.$2 > 0 ? 'Add' : 'Take off'} a step.';
}

/// Why the wall is never reached: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A runner sets off for a wall one length away and covers half of '
      'what is left at every step: half, then a quarter, then an eighth, and '
      'on. After seven steps 127/128 of the way is behind and 1/128 ahead; '
      'after twenty, 1/1,048,576 ahead; after any number, something. Zeno '
      'set it as a paradox in the fifth century BC, and the answer is that '
      'the endless steps add up to exactly the whole, 1/2 + 1/4 + 1/8 + ... = '
      '1, though no step is the last: the sum of the first n is 1 less 1/2 '
      'to the n, and that comes as near to 1 as you please. Any share does '
      'the same: nine tenths of what is left each time leaves a tenth, a '
      'hundredth, a thousandth.\n\n'
      'The game takes five shares, half, a third, two thirds, three quarters '
      'and nine tenths, and one to forty steps of each, ${Rules.settings} '
      'settings, adds the steps up as exact fractions and sets the sum against '
      '1 less the rest to the n; the two agree on all ${Rules.settings}, and '
      'the rest is never nothing.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every share and every count of '
      'steps on the dials, added out in full.';
}
