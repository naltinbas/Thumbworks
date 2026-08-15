import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the number, the taps taken to set it, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.number,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on ten: no ask is landed by that, and the checker
  /// says so.
  Play.of(this.level)
      : number = 10,
        moves = 0,
        before = null;

  /// A go standing at a number, no taps counted: what the mark draws.
  Play.standing(this.level, this.number)
      : moves = 0,
        before = null;

  final Level level;
  final int number;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets to 256.
  static const gaveUpAt = 40;

  List<int> get divisors => Rules.divisors(number);

  int get tithe => Rules.tithe(number);

  /// The tithe's own tithe, for the friends.
  int get tithesTithe => tithe >= 1 ? Rules.tithe(tithe) : 0;

  /// Winds the dial by [by], one or ten either way; a dial at its end
  /// stops there, and a wind that moves nothing is not a tap.
  Play wind(int by) {
    if (isOver || by == 0) return this;
    final n = (number + by).clamp(1, Rules.most);
    if (n == number) return this;
    return Play._(
      level: level,
      number: n,
      moves: moves + 1,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(number);

  /// A hopeless ask, admitted: the player has got to 256, the biggest
  /// power of two on the dial, or has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (number == 256 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the wind to take, ten or one either way,
  /// towards the aim; null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final gap = aim - number;
    if (gap == 0) return null;
    if (gap.abs() >= 10) return gap.sign * 10;
    return gap.sign;
  }

  /// The pointer's words.
  static String pointed(int by) => 'Wind ${by > 0 ? 'up' : 'down'} by ${by.abs()}.';
}

/// Why the tithe, and why the powers of two come short: the words
/// behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Add up a number\'s proper divisors, every divisor but the number '
      'itself, and the sum is its tithe. Most numbers get less than themselves '
      'back, some get more, and three of the first five hundred get exactly '
      'themselves: 6, 28 and 496, the perfect numbers, each a power of two '
      'times one less than the next power with that odd number prime, as '
      'Euclid built them. Two numbers can pay each other, 220 and 284. And a '
      'power of two always comes one short, since 1 + 2 + 4 + ... up to half '
      'of it is one less than it.\n\n'
      'The game adds the divisors up two ways, by trying every divisor in turn '
      'and by the formula from the prime factors, each prime\'s powers summed '
      'and the sums multiplied, and the two agree on every number of the '
      '${Rules.settings}.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every number from one to '
      '${Rules.settings}, tried in full.';
}
