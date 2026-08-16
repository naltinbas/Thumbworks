import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, the
/// bases tried on the clock, and the go before, so a tap can be taken
/// back.
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
  static const opening = 11;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets round every base.
  static const gaveUpAt = 12;

  /// The base's square on the clock.
  int get square => base * base % clock;

  /// The hours some base squares to, the first voice.
  Set<int> get squares => Rules.squaresByBases(clock);

  /// Whether the base's own hour is a square, by Euler's test, the
  /// second voice.
  bool get baseIsSquareByEuler => Rules.isSquareByEuler(base, clock);

  /// Turns dial [which] (0 the clock, 1 the base) by [by], one step
  /// either way; the clock steps prime to prime; a dial at its end
  /// stays, and that is not a tap. The base keeps below the clock.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    if (which == 0 && level.locked) return this;
    var c = clock, b = base;
    if (which == 0) {
      final i = Rules.clocks.indexOf(clock) + by.sign;
      if (i < 0 || i >= Rules.clocks.length) return this;
      c = Rules.clocks[i];
      if (b >= c) b = c - 1;
    } else {
      b += by.sign;
      if (b < 1 || b >= c) return this;
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

/// Why half the hours are squares, and which: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Take a prime clock and square every base on it, reading the hour '
      'the square lands on: on the seven-hour clock 1, 2, 3, 4, 5, 6 square '
      'to 1, 4, 2, 2, 4, 1, so 1, 2 and 4 are squares and 3, 5 and 6 are not. '
      'A base and its opposite, a and p - a, always land together, and no '
      'third base joins them, so exactly half the hours but 0 are squares. '
      'Euler found in 1748 a test that needs no squaring: raise the hour to '
      'the (p - 1) / 2 and it comes to 1 if the hour is a square and to '
      'p - 1 if not, never anything else. From the test come two old rules: '
      'one short of the clock is a square only on clocks one more than a '
      'multiple of four, and two is a square only on clocks one more or one '
      'less than a multiple of eight.\n\n'
      'The game squares every base on every prime clock to a hundred, '
      'twenty-four clocks, and sets Euler\'s test against the squares hour by '
      'hour; the two agree everywhere, the squares are half the hours but 0 '
      'on every clock, and the two rules hold on all twenty-four. The dials '
      'run over the eight prime clocks from three to twenty-three, '
      '${Rules.settings} settings.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every base of every clock the '
      'ask allows, squared in full.';
}
