import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two numbers set, the taps taken, the even sums
/// tried, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.x,
    required this.y,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : x = 3,
        y = 4,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at two numbers, no taps counted: what the mark draws.
  Play.standing(this.level, this.x, this.y)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The two numbers, x below y.
  final int x, y;

  /// The taps taken.
  final int moves;

  /// The even sums tried.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never tries three even sums.
  static const gaveUpAt = 16;

  /// The even sums a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 3;

  int get sum => x + y;
  int get product => x * y;

  /// The four things said, as they stand.
  (bool, bool, bool, bool) get said => Rules.said(x, y);

  List<(int, int)> get splitsOfProduct => Rules.splitsOfProduct(product);
  List<(int, int)> get splitsOfSum => Rules.splitsOfSum(sum);

  /// A split of the sum whose product tells P at once, the first, or
  /// null when every split leaves him in the dark.
  (int, int)? get tellingSplit {
    for (final q in splitsOfSum) {
      if (!Rules.pInDark(q.$1 * q.$2)) return q;
    }
    return null;
  }

  /// Steps [which], 'x' or 'y', by [by], if the pair stays a pair.
  Play step(String which, int by) {
    if (isOver) return this;
    final nx = which == 'x' ? x + by : x, ny = which == 'y' ? y + by : y;
    if (!Rules.valid(nx, ny)) return this;
    final nowSeen = (nx + ny).isEven ? {...seen, nx + ny} : seen;
    return Play._(level: level, x: nx, y: ny, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(x, y);

  /// A hopeless ask, admitted: [enough] even sums tried, each with its
  /// telling split, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && sum.isEven || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('x' or 'y', by), y towards the aim first
  /// when it can move, else x; null when there is nothing to point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (y != aim.$2) {
      final by = aim.$2 > y ? 1 : -1;
      if (Rules.valid(x, y + by)) return ('y', by);
    }
    if (x != aim.$1) {
      final by = aim.$1 > x ? 1 : -1;
      if (Rules.valid(x + by, y)) return ('x', by);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((String, int) aim) => 'Step ${aim.$1} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why one pair fits: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two whole numbers, each 2 or more, the smaller below the larger and '
      'the two adding to 100 at most. S is told their sum and P their '
      'product, and they speak in turn: P says he does not know the numbers, '
      'S says she knew he did not, P says now he does, and S says now she '
      'does too. Freudenthal set it in 1969, and Gardner called it the '
      'impossible puzzle, since it seems to give nothing away and yet one '
      'pair fits: 4 and 13, sum 17, product 52. Each thing said throws out '
      'pairs. P in the dark means his product splits more than one way; S '
      'knowing that means every split of her sum does; P then knowing means '
      'one split of his product alone has such a sum; and S then knowing '
      'means one split of her sum alone has such a product.\n\n'
      'The game takes every pair, 2,352, and asks the four things of each: '
      '1,747 leave P in the dark, 145 have a sum S could speak for, ten sums '
      'in all, 86 let P then know, and one lets S know too. It sieves the '
      'whole set again the other way, narrowing all the pairs by each thing '
      'said in turn, and the two agree at every step, down to 4 and 13.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sieve\'s: every pair of numbers, asked in '
      'full.';
}
