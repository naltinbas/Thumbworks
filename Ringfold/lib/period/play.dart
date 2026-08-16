import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the clock dialled, the taps taken to wind it, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.clock,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : clock = opening,
        moves = 0,
        before = null;

  /// A go standing at a clock, no taps counted: what the mark draws.
  Play.standing(this.level, this.clock)
      : moves = 0,
        before = null;

  final Level level;

  /// The clock's hours.
  final int clock;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// Where every ask opens: the two-hour clock, the one with an odd
  /// period.
  static const opening = 2;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never dials the four-hour clock.
  static const gaveUpAt = 12;

  /// The cycle of Fibonacci numbers on the clock, one period long.
  List<int> get cycle => Rules.cycle(clock);

  /// The period by walking, the first voice.
  int get period => cycle.length;

  /// The period by the matrix, the second voice.
  int get periodByMatrix => Rules.periodByMatrix(clock);

  /// Winds the clock by [by], ten or one either way, stopping at the
  /// dial's ends; a wind that cannot move is not a tap.
  Play wind(int by) {
    if (isOver || by == 0) return this;
    final c = (clock + by).clamp(Rules.least, Rules.most);
    if (c == clock) return this;
    return Play._(level: level, clock: c, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(clock);

  /// A hopeless ask, admitted: the four-hour clock is dialled, whose
  /// period of six is the shortest past two, or [gaveUpAt] taps are
  /// gone.
  bool get gaveUp => !level.winnable && (clock == 4 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the wind to take, ten or one either way,
  /// towards the aim; null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final gap = aim - clock;
    if (gap == 0) return null;
    if (gap.abs() >= 10) return gap.sign * 10;
    return gap.sign;
  }

  /// The pointer's words.
  static String pointed(int by) => 'Wind ${by > 0 ? 'up' : 'down'} by ${by.abs()}.';
}

/// Why the Fibonacci numbers come round, and always in an even count:
/// the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Write the Fibonacci numbers, 0, 1, 1, 2, 3, 5, 8, 13 and on, each '
      'the two before added, and cut every one down to its hour on a clock '
      'of m hours: on the three-hour clock they run 0, 1, 1, 2, 0, 2, 2, 1, '
      'and then 0, 1 comes round and the run repeats. It must: there are only '
      'm times m pairs of hours, so some pair comes twice, and the walk can '
      'be run backwards, each number the next less the one before, so the '
      'first pair to come twice is 0, 1 itself. Lagrange saw it in 1774. The '
      'period, the Pisano period, is 3, 8, 6, 20, 24, 16, 12, 24, 60 for two '
      'to ten hours, and it is even for every clock past two, since '
      'Cassini\'s identity, F(n - 1) F(n + 1) - F(n) squared = plus or minus '
      'one, turns its sign every step and comes back to plus one at the '
      'period.\n\n'
      'The game walks the Fibonacci numbers round every clock from two to '
      'forty hours until 0, 1 comes round, and finds each period again as the '
      'least divisor of a bound from the clock\'s prime factors that brings '
      'the Fibonacci matrix, 1 1 over 1 0, back to the identity by squaring; '
      'the two agree on all ${Rules.settings}, and to two hundred hours '
      'besides, and Cassini holds on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every clock on the dial, walked '
      'round in full.';
}
