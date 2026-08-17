import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which post hangs off which, the taps taken, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.hanging,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : hanging = Rules.opening,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a hanging, no taps counted: what the mark draws.
  Play.standing(this.level, this.hanging)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// What each post from 3 up hangs off.
  final List<int> hanging;

  /// The taps taken.
  final int moves;

  /// The hedges tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The hedges a hopeless ask lets the player build before the sham
  /// admits it.
  static const enough = 4;

  /// The posts left standing at the end of the peeling.
  List<int> get middle => Rules.peel(hanging).$1;

  /// How many rounds the peeling takes.
  int get rounds => Rules.peel(hanging).$2;

  /// The round each post falls in, 0 for the ones left standing.
  List<int> get fell => Rules.peel(hanging).$3;

  /// The longest walk through the hedge, end to end.
  int get longest => Rules.longest(hanging);

  List<(int, int)> get paths => Rules.paths(hanging);

  Play _to(List<int> to) {
    final nowSeen = !level.winnable ? {...seen, to.join(',')} : seen;
    return Play._(
      level: level,
      hanging: to,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Steps one dial: post [dial] + 3 hangs off one post further along,
  /// or one back.
  Play step(int dial, int by) {
    if (isOver || by == 0) return this;
    final to = List.of(hanging);
    to[dial] += by;
    if (!Rules.validHanging(to)) return this;
    return _to(to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(hanging);

  /// A hopeless ask, admitted: [enough] hedges tried, or [gaveUpAt]
  /// taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every hanging that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final hanging in Rules.hangings())
            if (level.meets(hanging)) hanging,
        ];
      });

  /// The nearest hanging that lands the ask, and how many taps away it
  /// is.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final win in winners(level)) {
      final taps = Rules.taps(hanging, win);
      if (away < 0 || taps < away) {
        away = taps;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: (dial, way); null when there is nothing to
  /// point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    for (var i = 0; i < Rules.hangs; i++) {
      if (hanging[i] != near.$1[i]) {
        return (i, hanging[i] < near.$1[i] ? 1 : -1);
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) {
    final post = aim.$1 + 3;
    return aim.$2 > 0
        ? 'Hang post $post off the next post along.'
        : 'Hang post $post off the post before.';
  }
}

/// Why the middle is never three posts: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A hedge of posts, every post reachable from every other and no '
      'path running in a loop. Strip every post that has a single path left, '
      'all of them at once, and then do it again. The hedge shrinks inward a '
      'ring at a time and stops with one post standing, or two. That is its '
      'middle.\n\n'
      'It is never three, and the longest walk through the hedge is why. The '
      'middle sits at the halfway mark of that walk: peeling takes a step off '
      'each end of it every round, so what survives is what lies halfway '
      'along. A walk of an even number of steps has one post at its halfway '
      'mark and a walk of an odd number has two, and there is no third place '
      'on a line to stand halfway. Camille Jordan wrote this down in 1869.\n\n'
      'The sham finds the middle twice over. It peels the hedge ring by ring '
      'without ever measuring a distance, and it walks outward from every '
      'post in turn and keeps the ones whose worst walk is shortest, without '
      'ever stripping anything. The two name the same posts on every hedge '
      'there is, and the rounds of the first come to half the longest walk, '
      'rounded down.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every hanging the dials '
      'reach, peeled in full before the sham was built.';
}
