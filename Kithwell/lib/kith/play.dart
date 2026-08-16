import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the friendships laid, the person held under the
/// thumb, the taps taken, the even plans reached, and the go before, so
/// a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.plan,
    required this.held,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : plan = 0,
        held = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a plan, no taps counted: what the mark draws.
  Play.standing(this.level, this.plan)
      : held = null,
        moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The friendships laid, as a mask.
  final int plan;

  /// The person tapped first, waiting for the second, or null.
  final int? held;

  /// The taps taken.
  final int moves;

  /// The plans reached on which the two averages agree.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never evens the fair.
  static const gaveUpAt = 40;

  /// The even plans a hopeless ask lets the player reach before the sham
  /// admits it.
  static const enough = 3;

  int get friendships => Rules.friendships(plan);

  List<int> get degrees => Rules.degrees(plan);

  Frac get average => Rules.average(plan);

  /// The friends' average, or null when nobody has a friend.
  Frac? get friendsAverage => Rules.friendsAverage(plan);

  /// The friends' average by the squares, the second voice.
  Frac? get friendsAverageBySquares => Rules.friendsAverageBySquares(plan);

  Frac? get gap => Rules.gap(plan);

  Frac get spread => Rules.spread(plan);

  /// A tap on person [v]: holds them when nobody is held, lets them go
  /// when they are the held one, else lays or lifts the friendship
  /// between the held person and them.
  Play tap(int v) {
    if (isOver || v < 0 || v >= Rules.people) return this;
    if (held == null) return Play._(level: level, plan: plan, held: v, moves: moves + 1, seen: seen, before: this);
    if (held == v) return Play._(level: level, plan: plan, held: null, moves: moves + 1, seen: seen, before: this);
    final next = Rules.toggled(plan, held!, v);
    final nowSeen = Rules.gap(next) == Frac.zero ? {...seen, next} : seen;
    return Play._(level: level, plan: next, held: null, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(plan);

  /// A hopeless ask, admitted: [enough] even plans reached, the gap at
  /// its least each time, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && gap == Frac.zero || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (a, b, lift), the friendship to lay or lift
  /// next towards the aim, one astray lifted first; with a person held
  /// who has no such friendship, (held, held, false) to let them go;
  /// null when there is nothing to point at.
  (int, int, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final diff = plan ^ aim;
    if (diff == 0) return null;
    final h = held;
    if (h != null) {
      for (var v = 0; v < Rules.people; v++) {
        if (v != h && diff & (1 << Rules.pairOf(h, v)) != 0) return (h, v, Rules.friends(plan, h, v));
      }
      return (h, h, false);
    }
    for (var i = 0; i < Rules.pairs.length; i++) {
      if (diff & (1 << i) != 0 && Rules.friends(plan, Rules.pairs[i].$1, Rules.pairs[i].$2)) {
        return (Rules.pairs[i].$1, Rules.pairs[i].$2, true);
      }
    }
    for (var i = 0; i < Rules.pairs.length; i++) {
      if (diff & (1 << i) != 0) return (Rules.pairs[i].$1, Rules.pairs[i].$2, false);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int, bool) aim, {int? held}) {
    final (a, b, lift) = aim;
    if (a == b) return 'Tap ${Rules.names[a]} again to let go.';
    if (held == a) return 'Now tap ${Rules.names[b]} to ${lift ? 'lift' : 'lay'} ${Rules.names[a]} and ${Rules.names[b]}\'s friendship.';
    return 'Tap ${Rules.names[a]}, then ${Rules.names[b]}, to ${lift ? 'lift' : 'lay'} their friendship.';
  }
}

/// Why the friends named are never behind: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Six people at the fair, and who knows whom. Count everyone\'s '
      'friends and take the average; then name every friendship from both '
      'ends, take down the named friend\'s count each time, and average those. '
      'The second is never below the first: your friends have more friends '
      'than you do, on average, and never fewer, as Feld set down in 1991. '
      'The reason is that a person with k friends is named k times, so the '
      'friends\' average is the sum of the squares of the counts over the sum '
      'of the counts, which is the plain average plus the spread of the '
      'counts over the average, and a spread is never below nought; it is '
      'nought exactly when everyone has the same number of friends.\n\n'
      'The game takes every plan of friendships among the six, 32,768, and on '
      'every one with a friendship in it finds the friends\' average twice, '
      'once by naming every friendship from both ends and once by the sum of '
      'the squares over the sum; the two agree on all 32,767, the friends '
      'named are never behind, level on the 171 plans where everyone has the '
      'same number of friends and ahead on the rest, and it finds the same '
      'person by person as well.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every plan of friendships among '
      'the six, named in full.';
}
