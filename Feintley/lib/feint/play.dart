import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the number and the base on their dials, the taps
/// taken, the primes tried, and the go before, so a tap can be taken
/// back.
class Play {
  const Play._({
    required this.level,
    required this.number,
    required this.base,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : number = 91,
        base = 2,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.number, this.base)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The number tested, and the base.
  final int number, base;

  /// The taps taken.
  final int moves;

  /// The primes tried on a base they do not divide.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never tries three primes.
  static const gaveUpAt = 20;

  /// The primes a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 3;

  bool get prime => Rules.isPrime(number);
  bool get coprime => Rules.gcd(base, number) == 1;
  int get landing => Rules.powMod(base, number - 1, number);
  int get landingWhole => Rules.powWhole(base, number - 1, number);
  bool get passes => Rules.passes(base, number);
  bool get liar => Rules.liar(base, number);
  bool get carmichael => Rules.carmichael(number);
  int? get factor => Rules.factor(number);

  /// Steps [which], 'n' or 'a', by [by], within the dials.
  Play step(String which, int by) {
    if (isOver) return this;
    final n = which == 'n' ? (number + by).clamp(Rules.least, Rules.most) : number;
    final a = which == 'a' ? (base + by).clamp(Rules.leastBase, Rules.mostBase) : base;
    if (n == number && a == base) return this;
    final nowSeen = Rules.isPrime(n) && Rules.gcd(a, n) == 1 ? {...seen, n} : seen;
    return Play._(level: level, number: n, base: a, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(number, base);

  /// A hopeless ask, admitted: [enough] primes tried on bases they do
  /// not divide, each passing, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && prime && coprime || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('n' or 'a', by), the number towards the aim
  /// by tens then ones, then the base; null when there is nothing to
  /// point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (number != aim.$1) {
      final d = aim.$1 - number;
      if (d.abs() >= 10) return ('n', d > 0 ? 10 : -10);
      return ('n', d > 0 ? 1 : -1);
    }
    if (base != aim.$2) return ('a', aim.$2 > base ? 1 : -1);
    return null;
  }

  /// The pointer's words.
  static String pointed((String, int) aim) => aim.$1 == 'n' ? 'Step the number ${aim.$2 > 0 ? 'up' : 'down'} by ${aim.$2.abs()}.' : 'Step the base ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why every prime passes: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Fermat\'s test: a number n is asked to raise a base a to the power '
      'n - 1, working modulo n all the way, and land on one. Every prime '
      'passes for every base it does not divide, as Fermat wrote in 1640 to '
      'Frenicle, leaving no proof; Euler published one in 1736. Take a prime '
      'p and a base a it does not divide: the multiples a, 2a and on to '
      '(p - 1)a leave the remainders 1 to p - 1 by p once each, since two '
      'alike would have p dividing a difference of the multipliers, so their '
      'product is (p - 1)! both times a to the p - 1 and plain, and the '
      'power is one. Composites mostly fail, 10,917 of the 11,033 settings '
      'with a composite here, which is why a test of this shape is the first '
      'thing a computer tries on a number, though the tests in use strengthen '
      'it; but some composites pass, liars for the base, 341 the first for '
      'base two, and a few pass on every base they share no factor with, '
      'Carmichael numbers, 561 the first.\n\n'
      'The game takes every number from 2 to 1,200 with every base from 2 to '
      '12, 13,189 settings, works the power by squaring modulo n and again '
      'taken whole and only then brought down, the two agreeing on all '
      '13,189; every one of the 196 primes passes on every base it does not '
      'divide, 2,142 settings, and 116 settings are liars, four for base two '
      'and seven for base three, with 561 and 1,105 the Carmichael numbers.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every number to 1,200 on every '
      'base, tested in full.';
}
