import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the first odd number and the count set, the taps
/// taken to set them, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.first,
    required this.count,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : first = 1,
        count = 1,
        moves = 0,
        before = null;

  /// A go standing at a run, no taps counted: what the mark draws.
  Play.standing(this.level, this.first, this.count)
      : moves = 0,
        before = null;

  final Level level;

  /// The first odd number of the run.
  final int first;

  /// How many odd numbers the run has.
  final int count;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never lands two either side of thirty.
  static const gaveUpAt = 12;

  List<int> get run => Rules.run(first, count);

  /// What the run adds to, added out, the first voice.
  int get sum => Rules.sumByAdding(first, count);

  /// What it adds to by the squares, the second voice.
  int get sumBySquares => Rules.sumBySquares(first, count);

  int get inner => Rules.inner(first);
  int get outer => Rules.outer(first, count);

  /// Turns dial [which] (0 the first odd number, by two, 1 the count, by
  /// one) by [by], either way; a dial at its end stays, and that is not
  /// a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var f = first, c = count;
    if (which == 0) {
      f += 2 * by.sign;
      if (f < 1 || f > Rules.firstMost) return this;
    } else {
      c += by.sign;
      if (c < 1 || c > Rules.countMost) return this;
    }
    return Play._(level: level, first: f, count: c, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(first, count);

  /// A hopeless ask, admitted: the run adds to 28 or 32, two either side
  /// of thirty, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (sum == level.number - 2 || sum == level.number + 2 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the first odd number first,
  /// then the count, each towards the aim; null when there is nothing
  /// to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (first != aim.$1) return (0, (aim.$1 - first).sign);
    if (count != aim.$2) return (1, (aim.$2 - count).sign);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Turn the ${aim.$1 == 0 ? 'first' : 'count'} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why odd numbers make squares, and what they never make: the words
/// behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Add the odd numbers from 1 and squares come out: 1, 1 + 3 = 4, '
      '1 + 3 + 5 = 9, 1 + 3 + 5 + 7 = 16, each new odd number an L of dots '
      'laid round the last square to make the next. Start the run higher and '
      'the sum is one square less another, the smaller square being the odd '
      'numbers left off: 5 + 7 + 9 is 25 less 4. So a run of consecutive odd '
      'numbers is always a difference of two squares, and it can never be '
      'two past a multiple of four: an odd count of odd numbers is odd, and '
      'an even count pairs off, each pair of neighbours a multiple of four.\n\n'
      'The game takes every run on the dials, the first odd number 1 to 99 '
      'and the count 1 to 20, 1,000 runs, adds each out and sets '
      'the sum against the outer square less the inner; the two agree on all '
      '1,000, the runs from 1 make the count squared every time, '
      'and no run makes 30, or 2, 6, 10 or any number two past a multiple '
      'of four.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every run on the dials, added '
      'out in full.';
}
