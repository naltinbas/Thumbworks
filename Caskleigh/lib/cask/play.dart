import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which casks the run takes, the taps taken, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.first,
    required this.last,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : first = Rules.openFirst,
        last = Rules.openLast,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a run, no taps counted: what the mark draws.
  Play.standing(this.level, this.first, this.last)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The first and last cask of the run.
  final int first, last;

  /// The taps taken.
  final int moves;

  /// The runs tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The runs a hopeless ask lets the player try before the sham admits
  /// it.
  static const enough = 4;

  /// What the run comes to.
  Frac get total => Rules.total(first, last);

  /// How many casks it takes.
  int get casks => last - first + 1;

  /// The cask with the most twos in it, which is always one alone.
  List<int> get deepest => Rules.deepest(first, last);

  int twosIn(int cask) => Rules.twos(cask);

  Play _to(int first, int last) {
    final nowSeen = !level.winnable ? {...seen, '$first,$last'} : seen;
    return Play._(
      level: level,
      first: first,
      last: last,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Steps the first cask of the run.
  Play stepFirst(int by) {
    final to = first + by;
    if (isOver || by == 0 || !Rules.validRun(to, last)) return this;
    return _to(to, last);
  }

  /// Steps the last cask of the run.
  Play stepLast(int by) {
    final to = last + by;
    if (isOver || by == 0 || !Rules.validRun(first, to)) return this;
    return _to(first, to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(first, last);

  /// A hopeless ask, admitted: [enough] runs tried, or [gaveUpAt] taps
  /// gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('first' or 'last', by); null when there is
  /// nothing to point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (first != aim.$1) return ('first', first < aim.$1 ? 1 : -1);
    if (last != aim.$2) return ('last', last < aim.$2 ? 1 : -1);
    return null;
  }

  /// The pointer's words.
  static String pointed((String, int) aim) {
    final which = aim.$1 == 'first' ? 'first' : 'last';
    return aim.$2 > 0
        ? 'Take the $which cask one further down the cellar.'
        : 'Take the $which cask one back up.';
  }
}

/// Why the total is never whole: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The casks of the cellar hold a whole barrel, a half, a third, a '
      'quarter and on down. Pour a run of them together and the total is a '
      'fraction; the ask is what that fraction comes to.\n\n'
      'It is never a whole barrel, and the reason is the twos. Among the '
      'numbers of any run there is exactly one with more twos in it than any '
      'other: if two of them had the same most twos, say two to the k times '
      'an odd number each, then between those two numbers would lie another '
      'multiple of two to the k plus one, with more twos than either, which '
      'contradicts it. Put the run over the smallest common bottom and every '
      'cask but that deepest one divides into it an even number of times, '
      'while the deepest divides in an odd number of times. So the top of '
      'the total is odd and the bottom is even, and an odd over an even is '
      'never whole. Jozsef Kurschak wrote it down in 1918, and Paul Erdos '
      'gave another proof in 1932 using Bertrand\'s postulate.\n\n'
      'The sham adds every run twice, once cask by cask in exact fractions '
      'and once over a common bottom in whole numbers, and marks the deepest '
      'cask on the board as you pour.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every run of casks the '
      'cellar allows, poured in full before the sham was built.';
}
