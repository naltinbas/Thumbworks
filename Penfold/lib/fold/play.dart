import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the call blown so far, where the flock stands, and
/// the go before, so a whistle can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.call,
    required this.flock,
    required this.before,
  });

  Play.of(this.level)
      : call = const [],
        flock = 15,
        before = null;

  /// A go standing part way through a call, no whistles counted: what
  /// the mark draws.
  Play.standing(this.level, this.call)
      : flock = Rules.afterCall(
          Rules.folds[level.fold]!,
          Rules.whole,
          call,
        ),
        before = null;

  final Level level;

  /// The whistles blown so far.
  final List<int> call;

  /// Which fields the sheep stand in.
  final int flock;

  final Play? before;

  /// The whistles a hopeless ask runs to before the sham admits it.
  /// There is nothing else to wait for: a fold whose whistles only turn
  /// the fields round leaves the flock in the one standing it began in,
  /// so the sham speaks when the whistles run out.
  static const gaveUpAt = 12;

  int get moves => call.length;

  /// How many fields the flock is spread over.
  int get spread => Rules.spread(flock);

  List<List<int>> get whistles => level.whistles;

  /// Blows whistle [which].
  Play blow(int which) {
    if (isOver || which < 0 || which >= Rules.whistles.length) return this;
    return Play._(
      level: level,
      call: [...call, which],
      flock: Rules.after(whistles, flock, which),
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.meets(flock);

  /// A hopeless ask, admitted: [gaveUpAt] whistles blown with the flock
  /// no narrower than it started.
  bool get gaveUp => !level.winnable && moves >= gaveUpAt;

  bool get isOver => isDone || gaveUp;

  /// How many whistles are still wanted, at best.
  int? get away => Rules.fewest(whistles, flock);

  /// The whistle the pointer names, or null.
  int? get next => isOver ? null : Rules.towards(whistles, flock);

  /// The pointer's words.
  static String pointed(int whistle) =>
      'Blow the ${whistle == 0 ? 'left' : 'right'} whistle.';
}

/// Why some folds cannot be gathered: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Four fields, four sheep, and two whistles. A whistle moves every '
      'sheep at once, each by where that whistle sends its field, and two '
      'sheep that land together stay together, so a flock only ever gets '
      'smaller. The ask is a call that leaves all four in one field.\n\n'
      'Jan Cerny gave the test for it in 1964: a fold can be gathered '
      'exactly when every two sheep can be brought together. One way round '
      'is plain, since gathering all four gathers any two of them. The other '
      'way is the work: bring two together, then treat the pair as one sheep '
      'and bring it to a third, and so on, and the flock comes in. It also '
      'means a fold whose whistles only turn the fields round can never be '
      'gathered, because no two sheep ever land together and the flock stays '
      'four wide.\n\n'
      'Cerny built the fold of four fields that needs the longest call, nine '
      'whistles, and guessed that a fold of n fields never needs more than n '
      'less one, squared. Nobody has proved it. For four fields it is a '
      'sweep rather than a guess: of all 65,536 folds of four fields and two '
      'whistles, 51,520 can be gathered, none needs more than nine whistles, '
      'and 96 need exactly nine.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every fold of four fields '
      'and two whistles, walked in full before the sham was built.';
}
