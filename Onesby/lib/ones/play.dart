import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the exponent dialled, the taps taken to wind it,
/// the composite exponents seen, and the go before, so a tap can be
/// taken back.
class Play {
  const Play._({
    required this.level,
    required this.exponent,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : exponent = opening,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at an exponent, no taps counted: what the mark draws.
  Play.standing(this.level, this.exponent)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;
  final int exponent;

  /// The taps taken.
  final int moves;

  /// The composite exponents dialled so far.
  final Set<int> seen;

  final Play? before;

  /// Where every ask opens: two ones, the number 3.
  static const opening = 2;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never sees enough composite exponents.
  static const gaveUpAt = 12;

  /// How many composite exponents the sham lets the player try before
  /// admitting the hopeless ask.
  static const enough = 4;

  BigInt get row => Rules.row(exponent);

  bool get exponentIsPrime => Rules.isPrime(exponent);

  /// Whether the row is prime, by trial division, the first voice.
  bool get rowIsPrime => Rules.rowIsPrimeByDivision(exponent);

  /// Whether the row is prime by Lucas and Lehmer, the second voice.
  bool get rowIsPrimeByLucasLehmer => Rules.rowIsPrimeByLucasLehmer(exponent);

  /// The row's smallest factor, or the row itself when prime.
  BigInt get factor => Rules.smallestFactor(row);

  /// Winds the exponent by [by], ten or one either way, stopping at the
  /// dial's ends; a wind that cannot move is not a tap.
  Play wind(int by) {
    if (isOver || by == 0) return this;
    final e = (exponent + by).clamp(Rules.least, Rules.most);
    if (e == exponent) return this;
    return Play._(
      level: level,
      exponent: e,
      moves: moves + 1,
      seen: Rules.isPrime(e) ? seen : {...seen, e},
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(exponent);

  /// A hopeless ask, admitted: [enough] composite exponents have shown
  /// their factor, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the wind to take, ten or one either way,
  /// towards the aim; null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final gap = aim - exponent;
    if (gap == 0) return null;
    if (gap.abs() >= 10) return gap.sign * 10;
    return gap.sign;
  }

  /// The pointer's words.
  static String pointed(int by) => 'Wind ${by > 0 ? 'up' : 'down'} by ${by.abs()}.';
}

/// Why a row of ones can be prime only when its length is: the words
/// behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Write p ones in binary and you have 2 to the p less 1: three ones '
      'are 7, five ones 31, seven ones 127, all prime, and Mersenne\'s '
      'numbers, as they are called, hold the biggest primes anyone knows. But '
      'if p is a times b, the row of a ones divides the row of p ones, since '
      '2 to the ab less 1 is 2 to the a less 1 times a sum of powers, so a '
      'prime row needs a prime length; and a prime length is not enough, '
      'eleven ones being 2,047, which is 23 times 89. Every prime row makes '
      'a perfect number, 2 to the p - 1 times the row, as Euclid showed, and '
      'Euler showed every even perfect number comes so.\n\n'
      'The game takes every exponent from ${Rules.least} to ${Rules.most} '
      'and tells its row prime or not twice over: by trial division to the '
      'square root, and by the Lucas-Lehmer chain, 4 and then each the last '
      'squared less two, cut down by the row, which ends at 0 exactly for the '
      'prime rows. The two agree on all ${Rules.settings}; every composite '
      'exponent shows the row of its smallest prime factor as a factor, and '
      'the perfect numbers made, up to 137,438,691,328, are checked by adding '
      'their divisors.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every exponent on the dial, its '
      'row told prime or not both ways.';
}
