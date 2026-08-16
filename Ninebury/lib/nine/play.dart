import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three dials, the taps taken to set them, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.digits,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : digits = const [0, 0, 0],
        moves = 0,
        before = null;

  /// A go standing at a number, no taps counted: what the mark draws.
  Play.standing(this.level, int number)
      : digits = Rules.digits(number),
        moves = 0,
        before = null;

  final Level level;

  /// The hundreds, the tens and the units, 0 to 9 each.
  final List<int> digits;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never dials a square with root 4 or 7.
  static const gaveUpAt = 15;

  static const names = ['hundreds', 'tens', 'units'];

  int get number => digits[0] * 100 + digits[1] * 10 + digits[2];

  /// The sums down to one digit, the first voice.
  List<int> get chain => Rules.chain(number);

  int get root => Rules.rootByDigits(number);

  /// The root by the second voice.
  int get rootByNines => Rules.rootByNines(number);

  /// Turns dial [which] (0 hundreds, 1 tens, 2 units) by [by], one step
  /// either way; a dial at its end stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    final d = List.of(digits);
    d[which] += by.sign;
    if (d[which] < 0 || d[which] > 9) return this;
    return Play._(level: level, digits: d, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(number);

  /// A hopeless ask, admitted: a square with root 4 or 7 is on the
  /// dials, either side of five, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (Rules.isSquare(number) && (root == 4 || root == 7) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the hundreds first, then the
  /// tens, then the units, each towards the aim; null when there is
  /// nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = Rules.digits(aim);
    for (var i = 0; i < 3; i++) {
      if (digits[i] != want[i]) return (i, (want[i] - digits[i]).sign);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Turn the ${names[aim.$1]} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why the digits keep the remainder: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Add the digits of a number, then the digits of that, until one '
      'digit is left: 738 gives 7 + 3 + 8 = 18 and 1 + 8 = 9, its root. The '
      'root is the remainder by nine, with nine standing for nought, because '
      '10, 100 and 1,000 are each one more than a multiple of nine, so a '
      'digit in any place counts for itself alone: 738 is 82 nines and 0 '
      'over, and 451 is 50 nines and 1 over, root 1. Casting out nines, the '
      'old check on sums and products, is just this: the root of a sum is '
      'the root of the roots added, the root of a product the root of the '
      'roots multiplied, and a slip that changes the root shows.\n\n'
      'The game takes every number of three digits, 0 to 999, adds its digits '
      'down and takes its remainder by nine, and the two agree on all 1,000; '
      'it adds and multiplies every pair, a million of them, and the roots '
      'keep step; and it sweeps the squares to 961 and the cubes to 729 for '
      'the roots they can bear.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: all thousand numbers the dials '
      'reach, rooted both ways.';
}
