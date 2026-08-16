import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the roads laid, the village held under the thumb,
/// the taps taken, the plans that met Dirac's rule, and the go before,
/// so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.roads,
    required this.held,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : roads = 0,
        held = null,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a road-plan, no taps counted: what the mark draws.
  Play.standing(this.level, this.roads)
      : held = null,
        moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The roads laid, as a mask.
  final int roads;

  /// The village tapped first, waiting for the second, or null.
  final int? held;

  /// The taps taken.
  final int moves;

  /// The road-plans seen with three roads or more at every village.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gives every village three roads.
  static const gaveUpAt = 40;

  /// The plans meeting Dirac's rule a hopeless ask lets the player build
  /// before the sham admits it.
  static const enough = 3;

  int get roadCount => Rules.roads(roads);

  List<int> get degrees => Rules.degrees(roads);

  int get minDegree => Rules.minDegree(roads);

  bool get dirac => Rules.dirac(roads);

  bool get ore => Rules.ore(roads);

  /// The round trip found by walking, or null.
  List<int>? get trip => Rules.tripByWalk(roads);

  /// Whether the table finds a round trip too, the second voice.
  bool get tripByTable => Rules.tripByTable(roads);

  /// A tap on village [v]: holds it when none is held, lets it go when
  /// it is the held one, else lays or lifts the road between the held
  /// village and it.
  Play tap(int v) {
    if (isOver || v < 0 || v >= Rules.villages) return this;
    if (held == null) return Play._(level: level, roads: roads, held: v, moves: moves + 1, seen: seen, before: this);
    if (held == v) return Play._(level: level, roads: roads, held: null, moves: moves + 1, seen: seen, before: this);
    final next = Rules.toggled(roads, held!, v);
    final nowSeen = Rules.dirac(next) ? {...seen, next} : seen;
    return Play._(level: level, roads: next, held: null, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(roads);

  /// A hopeless ask, admitted: [enough] plans with three roads at every
  /// village have been laid, each with its round trip, or [gaveUpAt]
  /// taps are gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && dirac || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (a, b, lift), the road to lay or lift next
  /// towards the aim, a road astray lifted first; with a village held
  /// that has no such road, (held, held, false) to let it go; null when
  /// there is nothing to point at.
  (int, int, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final diff = roads ^ aim;
    if (diff == 0) return null;
    final h = held;
    if (h != null) {
      for (var v = 0; v < Rules.villages; v++) {
        if (v != h && diff & (1 << Rules.roadOf(h, v)) != 0) return (h, v, Rules.joined(roads, h, v));
      }
      return (h, h, false);
    }
    for (var i = 0; i < Rules.pairs.length; i++) {
      if (diff & (1 << i) != 0 && Rules.joined(roads, Rules.pairs[i].$1, Rules.pairs[i].$2)) {
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
    if (a == b) return 'Tap ${Rules.names[a]} again to let it go.';
    if (held == a) return 'Now tap ${Rules.names[b]} to ${lift ? 'lift' : 'lay'} the road ${Rules.names[a]}${Rules.names[b]}.';
    return 'Tap ${Rules.names[a]}, then ${Rules.names[b]}, to ${lift ? 'lift' : 'lay'} the road ${Rules.names[a]}${Rules.names[b]}.';
  }
}

/// Why three roads each is enough: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Six villages, and roads to lay between them, fifteen possible. A '
      'round trip goes through every village once and comes home. Dirac '
      'proved in 1952 that if every village has half the others as '
      'neighbours at least, three of the five here, a round trip is there '
      'whatever the roads: take a longest walk that repeats no village; every '
      'neighbour of either end is on it, or the walk could be longer, and '
      'with three neighbours each the two ends have neighbours enough on it '
      'that some road from one end lands just after a road from the other, '
      'so the walk closes into a ring, and a ring that missed a village could '
      'be opened and stretched to take it in. Ore widened it in 1960: it is '
      'enough that any two villages not joined have six roads between them.\n\n'
      'The game takes every road-plan on the six villages, 32,768, looks for a '
      'round trip on each two ways, by walking every order of the villages '
      'and by a table of what sets of villages a walk from A can end where, '
      'and the two agree on all 32,768: 10,078 plans have a round trip, and '
      'every one of the 1,858 with three roads or more at every village does, '
      'and every one of the 1,978 meeting Ore\'s rule.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every road-plan on the six '
      'villages, walked in full.';
}
