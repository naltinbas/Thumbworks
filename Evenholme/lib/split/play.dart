import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the number picked, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.picked,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : picked = null,
        moves = 0,
        before = null;

  /// A play stood at a pick, for the mark and the tests.
  Play.standing(this.level, int a)
      : picked = a,
        moves = 0,
        before = null;

  final Level level;

  /// The number picked, or null; its partner is the number less it.
  final int? picked;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if 2 is never
  /// picked.
  static const gaveUpAt = 20;

  int? get partner => picked == null ? null : level.number - picked!;

  bool get pickedPrime => picked != null && Rules.isPrime(picked!);
  bool get partnerPrime => partner != null && Rules.isPrime(partner!);

  /// Taps a number: from 2 to two short of the number it is picked, and
  /// tapping the pick, or its partner, lets go.
  Play tap(int a) {
    if (isOver || a < 2 || a > level.number - 2) return this;
    final next = (a == picked || a == partner) ? null : a;
    return Play._(level: level, picked: next, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && picked != null && level.meets(picked!);

  /// A hopeless ask, admitted: 2 is picked, the one pick an odd number
  /// could split by, and its partner is not prime; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && ((picked == 2 || partner == 2) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the number to tap, the aim; null when the aim
  /// is picked or there is none.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (picked == aim || partner == aim) return null;
    return aim;
  }

  static String pointed(int a) => 'Tap $a.';
}

/// Why the splits, and why the odd never: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Goldbach wrote to Euler in 1742 that every even number past two '
      'seems to be two primes added together, and nobody has found one that '
      'is not, nor proved that none exists. The game sifts the primes to '
      '2,000 with Eratosthenes\' sieve and again by trial division, and the '
      'two agree number for number, 303 primes; and it splits every even '
      'number from 4 to 2,000 into two primes every way it can, and finds at '
      'least one way for every one. An odd number is another matter: two odd '
      'primes make an even number, so an odd one splits only with a 2 in it, '
      'and then only when two less than it is prime.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every pick from 2 to half the '
      'number, tried in full.';
}
