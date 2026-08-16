import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, the
/// bases tried, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.clock,
    required this.base,
    required this.moves,
    required this.tried,
    required this.before,
  });

  Play.of(this.level)
      : clock = level.clock ?? opening,
        base = 1,
        moves = 0,
        tried = const {1},
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.clock, this.base)
      : moves = 0,
        tried = const {},
        before = null;

  final Level level;
  final int clock;
  final int base;

  /// The taps taken.
  final int moves;

  /// The bases tried on this clock, the opening one among them.
  final Set<int> tried;

  final Play? before;

  /// The clock a free ask opens on.
  static const opening = 12;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets round every base.
  static const gaveUpAt = 12;

  /// The walk of the base on the clock, the first voice.
  List<int> get walk => Rules.walk(base, clock);

  /// The steps home, or null when the walk never comes home.
  int? get order => Rules.orderByWalk(base, clock);

  /// The order by the second voice, from Carmichael's lambda.
  int? get orderByLambda => Rules.orderByLambda(base, clock);

  bool get comesHome => order != null;

  /// Turns dial [which] (0 the clock, 1 the base) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap. The
  /// base keeps below the clock, so a clock turned down past it drags it
  /// down too.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    if (which == 0 && level.locked) return this;
    var c = which == 0 ? clock + by.sign : clock;
    var b = which == 1 ? base + by.sign : base;
    if (c < Rules.least || c > Rules.most || b < 1) return this;
    if (b >= c) {
      if (which == 1) return this;
      b = c - 1;
    }
    return Play._(
      level: level,
      clock: c,
      base: b,
      moves: moves + 1,
      tried: c == clock ? {...tried, b} : {b},
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(clock, base);

  /// A hopeless ask, admitted: every base of the clock has been tried,
  /// or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (tried.length >= clock - 1 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the clock first, then the base,
  /// each towards the aim; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (clock != aim.$1) return (0, (aim.$1 - clock).sign);
    if (base != aim.$2) return (1, (aim.$2 - base).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Turn the ${aim.$1 == 0 ? 'clock' : 'base'} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why some clocks have a full base and some none: the words behind the
/// Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Take a clock of so many hours and a base, and walk: start at 1, '
      'multiply by the base, and read the hour the product lands on, round '
      'and round. On the seven-hour clock the base 3 walks 1, 3, 2, 6, 4, 5 '
      'and comes home to 1 on the sixth step, having touched every hour but '
      '0: a full base, a primitive root, as Euler named it. The base 2 walks '
      '1, 2, 4 and is home in three. A base sharing a factor with the clock '
      'never comes home at all: 2 on the twelve-hour clock walks 1, 2, 4, 8 '
      'and then rounds 4, 8, 4, 8 for ever.\n\n'
      'Gauss proved in 1801 which clocks have a full base: 2, 4, a power of '
      'an odd prime, or twice one, and no other. Every prime clock does, '
      'phi of one less of them; eight does not, since every odd number '
      'squared is one more than a multiple of eight.\n\n'
      'The game walks every base of every clock from three to twenty-four '
      'hours, ${Rules.settings} settings, and again from three to a hundred, '
      'and sets each walk against a second reckoning that never walks: '
      'Carmichael\'s lambda from the clock\'s prime factors, and the base '
      'raised to lambda\'s divisors by squaring. The two agree on the steps '
      'home of every base, and the clocks with a full base are exactly '
      'the ones Gauss\'s rule names.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every base of every clock the '
      'ask allows, walked in full.';
}
