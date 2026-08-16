import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two counts on their dials, the taps taken, the
/// coprime counts tried, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.first,
    required this.second,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : first = 6,
        second = 9,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at two counts, no taps counted: what the mark draws.
  Play.standing(this.level, this.first, this.second)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The two counts.
  final int first, second;

  /// The taps taken.
  final int moves;

  /// The settings tried whose counts share no factor.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never tries three coprime counts.
  static const gaveUpAt = 16;

  /// The coprime settings a hopeless ask lets the player try before the
  /// sham admits it.
  static const enough = 3;

  BigInt get firstHedge => Rules.fib(first);
  BigInt get secondHedge => Rules.fib(second);

  /// The yardstick by Euclid on the hedges.
  BigInt get measure => Rules.measureByHedges(first, second);

  /// The yardstick by the counts, the second voice.
  BigInt get measureByCounts => Rules.measureByCounts(first, second);

  int get commonCount => Rules.gcd(first, second);

  List<(int, int)> get euclid => Rules.euclidOnCounts(first, second);

  bool get firstMeasuresSecond => Rules.divides(first, second);

  /// Steps [which], 'm' or 'n', by [by], within one and thirty.
  Play step(String which, int by) {
    if (isOver) return this;
    final a = which == 'm' ? first + by : first, b = which == 'n' ? second + by : second;
    if (a < 1 || a > Rules.most || b < 1 || b > Rules.most || (a == first && b == second)) return this;
    final nowSeen = Rules.gcd(a, b) == 1 ? {...seen, '$a,$b'} : seen;
    return Play._(level: level, first: a, second: b, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(first, second);

  /// A hopeless ask, admitted: [enough] coprime settings tried, each with
  /// a yardstick of one, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && commonCount == 1 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('m' or 'n', by), the first count towards
  /// the aim's, then the second; null when there is nothing to point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (first != aim.$1) return ('m', aim.$1 > first ? 1 : -1);
    if (second != aim.$2) return ('n', aim.$2 > second ? 1 : -1);
    return null;
  }

  /// The pointer's words.
  static String pointed((String, int) aim) => 'Step the ${aim.$1 == 'm' ? 'first' : 'second'} count ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why the hedges share what the counts share: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two hedges, the first of the mth Fibonacci length and the second '
      'of the nth, 1, 1, 2, 3, 5, 8, 13 and on, each the two before it added, '
      'and the longest yardstick that measures both without remainder. It is '
      'the Fibonacci number of the common measure of m and n: two Fibonacci '
      'numbers share exactly the factors their counts share, as Lucas set '
      'down in 1876. The reason is that the (m + n)th is the (m - 1)th times '
      'the nth plus the mth times the (n + 1)th, so a factor common to the '
      'mth and the nth is common to the mth and the (n - m)th, and Euclid '
      'runs on the counts as it runs on the hedges. And one Fibonacci number '
      'measures another exactly when its count divides the other\'s, the '
      'first two hedges of one aside.\n\n'
      'The game takes every pair of counts from one to thirty, 900 settings, '
      'finds the yardstick by Euclid on the two hedges themselves, big as '
      'they are, and again as the Fibonacci number of the counts\' common '
      'measure; the two agree on all 900, and one hedge measures the other '
      'exactly when the counts say so, on all 900 too.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every pair of counts to thirty, '
      'measured in full.';
}
