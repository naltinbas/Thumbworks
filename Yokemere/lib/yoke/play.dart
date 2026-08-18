import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: how the off row is yoked, the swaps made, and the
/// go before, so a swap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.order,
    required this.held,
    required this.swaps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : order = const [4, 3, 2, 1, 0],
        held = null,
        swaps = 0,
        seen = const {},
        before = null;

  /// A go yoked as it stands and no swaps counted: what the mark draws.
  const Play.yoked(this.level, this.order)
      : held = null,
        swaps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Which off ox stands at each place of the team.
  final List<int> order;

  /// The place the hand has hold of, waiting for its partner, or null.
  final int? held;

  final int swaps;

  /// The teams tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The swaps a hopeless ask runs to before the yard admits it.
  static const gaveUpAt = 14;

  /// The teams a hopeless ask lets the player try before the yard admits
  /// it.
  static const enough = 6;

  /// What the team pulls as it stands.
  int get pull => Rules.pull(order);

  /// The off ox yoked at a place.
  int oxAt(int place) => Rules.off[order[place]];

  String get mark => order.join();

  /// The places that are crossed against a given place, meaning the
  /// stronger near ox is yoked to the weaker off one.
  List<int> crossedWith(int place) => [
        for (var j = 0; j < Rules.oxen; j++)
          if (j != place && Rules.crossed(order, place, j)) j,
      ];

  /// Whether any two places at all are crossed. A team with none is the
  /// matching order, which pulls hardest.
  bool get anyCrossed {
    for (var i = 0; i < Rules.oxen; i++) {
      for (var j = i + 1; j < Rules.oxen; j++) {
        if (Rules.crossed(order, i, j)) return true;
      }
    }
    return false;
  }

  /// Takes hold of a place, or swaps it with the one already held.
  Play tap(int place) {
    if (isOver || place < 0 || place >= Rules.oxen) return this;
    final hand = held;
    if (hand == null) {
      return Play._(
        level: level,
        order: order,
        held: place,
        swaps: swaps,
        seen: seen,
        before: before,
      );
    }
    if (hand == place) {
      return Play._(
        level: level,
        order: order,
        held: null,
        swaps: swaps,
        seen: seen,
        before: before,
      );
    }
    final to = Rules.swap(order, hand, place);
    return Play._(
      level: level,
      order: to,
      held: null,
      swaps: swaps + 1,
      seen: !level.winnable ? {...seen, to.join()} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(order);

  /// A hopeless ask, admitted: [enough] teams tried, or [gaveUpAt]
  /// swaps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || swaps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every yoking that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) => _winners.putIfAbsent(
      level.name,
      () => [
            for (final y in Rules.yokings())
              if (level.meets(y)) y,
          ]);

  /// The nearest yoking that lands the ask, and the swaps to it.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final win in winners(level)) {
      final n = Rules.between(order, win);
      if (away < 0 || n < away) {
        away = n;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the two places to swap. Null when there is
  /// nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // A swap that puts one place right and takes another off a place it
    // does not belong in shortens the walk by one.
    for (var i = 0; i < Rules.oxen; i++) {
      if (order[i] == near.$1[i]) continue;
      for (var j = 0; j < Rules.oxen; j++) {
        if (i == j || order[j] == near.$1[j]) continue;
        if (Rules.between(Rules.swap(order, i, j), near.$1) < near.$2) {
          return (i, j);
        }
      }
    }
    return null;
  }

  /// The pointer's words.
  String pointed((int, int) aim) {
    if (held == null) {
      return 'Take hold of place ${aim.$1 + 1}, then place ${aim.$2 + 1}.';
    }
    if (held == aim.$1) return 'Now take place ${aim.$2 + 1}.';
    if (held == aim.$2) return 'Now take place ${aim.$1 + 1}.';
    return 'Let go of place ${held! + 1} first, then swap '
        '${aim.$1 + 1} with ${aim.$2 + 1}.';
  }
}

/// Why the matching order pulls hardest: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two rows of oxen, near and off, yoked one to one. The near row '
      'stands as it is; the off row is yours to swap about. A pair pulls '
      'what the two beasts multiply to, and the team pulls those added '
      'up.\n\n'
      'Take any two places and look at them. If the stronger near ox is '
      'yoked to the weaker off ox, call the pair crossed. Swap the two '
      'off oxen over and see what happens to the pull: everything else '
      'stays as it was, and the change comes to the near gap multiplied '
      'by the off gap. When the pair was crossed those two gaps run '
      'opposite ways, so the change is never a loss.\n\n'
      'That is the whole proof, and it is a move you can make with your '
      'thumb. A team with no crossed pair anywhere is the one with both '
      'rows in matching order, strongest with strongest. Any other team '
      'has a crossed pair, and working the crossings out one at a time '
      'walks up towards that matching order and never walks back. So the '
      'matching order pulls hardest of all, and nothing gets past it. '
      'Sorting the rows opposite ways gives the softest pull the same '
      'way round.\n\n'
      'Here the matching order pulls ${Rules.hardest()} and the opposite '
      'order pulls ${Rules.softest()}, which is where every ask starts. '
      'The yard settles it twice: it tries all 120 yokings and reads the '
      'hardest and softest off them, and it also sorts the two rows and '
      'multiplies place by place, which yokes nobody at all. The two '
      'agree here and on 15,876 other pairs of rows besides, 1,905,120 '
      'yokings in all.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
