import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the wheels stand, the turns taken, and the
/// go before, so a turn can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.wheels,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : wheels = const [0, 0, 0, 0, 0],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a reading, no turns counted: what the mark draws.
  Play.standing(this.level, this.wheels)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Where each wheel stands, the first wheel first.
  final List<int> wheels;

  /// The turns taken.
  final int moves;

  /// The readings tried on a hopeless ask.
  final Set<int> seen;

  final Play? before;

  /// The turns a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 20;

  /// The readings a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 4;

  /// What the house reads.
  int get reading => Rules.reading(wheels);

  /// How far the reading is from the top.
  int get under => Rules.most - reading;

  Play _to(List<int> to) {
    final at = Rules.reading(to);
    return Play._(
      level: level,
      wheels: to,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Turns one wheel, counting the wheels from 1.
  Play turn(int wheel, int by) {
    if (isOver || by == 0) return this;
    final to = List.of(wheels);
    to[wheel - 1] += by;
    if (!Rules.valid(to)) return this;
    return _to(to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(wheels);

  /// A hopeless ask, admitted: [enough] readings tried, or [gaveUpAt]
  /// turns taken.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// How many turns are left to the ask, or null when the ask cannot be
  /// read at all.
  int? get toGo {
    final aim = level.aim;
    return aim == null ? null : Rules.turns(wheels, aim);
  }

  /// What the pointer says: (wheel, way); null when there is nothing to
  /// point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var k = 1; k <= Rules.wheels; k++) {
      if (wheels[k - 1] != aim[k - 1]) {
        return (k, wheels[k - 1] < aim[k - 1] ? 1 : -1);
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => aim.$2 > 0
      ? 'Turn the ${Rules.tellWorth(aim.$1)} wheel up one.'
      : 'Turn the ${Rules.tellWorth(aim.$1)} wheel down one.';
}

/// Why the house stops at 719: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Five wheels, and no two of them the same size. The first turns 0 or '
      '1, the second 0 to 2, the third 0 to 3, the fourth 0 to 4, the fifth 0 '
      'to 5, and a turn of each is worth 1, 2, 6, 24 and 120: the factorials. '
      'The house reads the wheels added up, each times its worth.\n\n'
      'Turn them all to their tops and the house reads 719, which is 6 '
      'factorial less one, and it will read no higher. The reason is a '
      'folding sum. A wheel at its top is worth k times k factorial, and k '
      'times k factorial is (k + 1) factorial less k factorial: 1 times 1 is '
      '2 less 1, 2 times 2 is 6 less 2, 3 times 6 is 24 less 6, and on. Add '
      'those from the first wheel to the fifth and everything in the middle '
      'cancels, leaving 6 factorial less 1 factorial, which is 720 less 1.\n\n'
      'That is also why every number below it reads exactly one way. There '
      'are 720 settings of the wheels and 720 numbers from nothing to 719, '
      'and no two settings read the same, since if the cheapest wheel they '
      'differ on is the kth, the wheels below it cannot make up k factorial '
      'between them: at their tops they come to k factorial less one.\n\n'
      'The sham reads every setting twice: once by adding the wheels up, and '
      'once by counting the house up a tick at a time from nothing, carrying '
      'as an odometer does, and seeing which tick each setting falls on.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every setting of the wheels '
      'read in full before the sham was built.';
}
