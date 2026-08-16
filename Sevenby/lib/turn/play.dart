import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.prime,
    required this.top,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : prime = opening,
        top = 1,
        moves = 0,
        before = null;

  /// A go standing at a fraction, no taps counted: what the mark draws.
  Play.standing(this.level, this.prime, this.top)
      : moves = 0,
        before = null;

  final Level level;

  /// The prime under the line.
  final int prime;

  /// The number over the line, 1 to prime - 1.
  final int top;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The prime every ask opens on: eleven, whose decimal comes round in
  /// two.
  static const opening = 11;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never dials a full turn.
  static const gaveUpAt = 12;

  /// The digits of the block and the remainders, by long division.
  (List<int>, List<int>) get division => Rules.divide(top, prime);

  List<int> get digits => division.$1;
  List<int> get remainders => division.$2;

  /// The period by long division, the first voice.
  int get period => digits.length;

  /// The period by the clock, the second voice.
  int get periodByClock => Rules.periodByClock(prime);

  bool get isFullTurn => period == prime - 1;

  /// Turns dial [which] (0 the prime, 1 the top) by [by], one step
  /// either way; the prime steps prime to prime; a dial at its end
  /// stays, and that is not a tap. The top keeps below the prime.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var p = prime, k = top;
    if (which == 0) {
      final i = Rules.primes.indexOf(prime) + by.sign;
      if (i < 0 || i >= Rules.primes.length) return this;
      p = Rules.primes[i];
      if (k >= p) k = p - 1;
    } else {
      k += by.sign;
      if (k < 1 || k >= p) return this;
    }
    return Play._(level: level, prime: p, top: k, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(prime, top);

  /// A hopeless ask, admitted: a full turn is on the dial, the longest
  /// there is, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (isFullTurn || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the prime first, then the top,
  /// each towards the aim; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (prime != aim.$1) return (0, (aim.$1 - prime).sign);
    if (top != aim.$2) return (1, (aim.$2 - top).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Turn the ${aim.$1 == 0 ? 'prime' : 'top'} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why the decimal comes round, and how soon: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Divide 1 by 7 the long way and the digits come 1, 4, 2, 8, 5, 7 '
      'and then round again, since the remainders run 1, 3, 2, 6, 4, 5 and '
      'come back to 1: 0.142857 repeating. Every fraction over a prime but 2 '
      'and 5 repeats so, and the length of the block, the period, is how '
      'many steps 10 takes to come back to 1 on the p-hour clock, a divisor '
      'of p - 1 and never more, because only p - 1 remainders exist and one '
      'must come again. When the period is the whole p - 1, as for 7, 17, '
      '19, 23, 29 and 47, the block times p is a row of nines and every k '
      'over p reads the same digits from another start; and whenever the '
      'period is even, the two halves of the block add to nines, 142 + 857 '
      'being 999, which is Midy\'s theorem.\n\n'
      'The game divides every k by every prime on the dial the long way, '
      '${Rules.settings} fractions, and sets each period against the steps of '
      '10 round the clock; the two agree on all ${Rules.settings}, every '
      'period divides p - 1, every block times p is nines, and Midy holds on '
      'every even period.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every fraction the dials reach, '
      'divided out in full.';
}
