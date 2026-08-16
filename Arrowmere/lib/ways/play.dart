import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which way each street points, the turns taken, the
/// orientations that got as far as the village allows, and the go
/// before, so a turn can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.arrows,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : arrows = level.village.opening,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at an orientation, no turns counted: what the mark
  /// draws.
  Play.standing(this.level, this.arrows)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// One arrow to a street: false points it the way the village lists
  /// it, true turns it about.
  final List<bool> arrows;

  /// The turns taken.
  final int moves;

  /// The orientations tried that got as many pairs open as the village
  /// allows.
  final Set<String> seen;

  final Play? before;

  /// The turns a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 14;

  /// The best-it-gets orientations a hopeless ask lets the player find
  /// before the sham admits it.
  static const enough = 3;

  Village get village => level.village;

  /// How many ordered pairs of places can be got between.
  int get pairs => Rules.pairs(village, arrows);

  /// How many there are to get between.
  int get wanted => level.pairsWanted;

  /// Every place reachable from every other.
  bool get roundabout => pairs == wanted;

  /// Whether [place] has no arrow pointing into it, so nobody can get
  /// there, or none pointing out, so nobody can leave.
  bool stranded(int place) {
    var into = 0, outof = 0;
    for (var s = 0; s < village.streetCount; s++) {
      final (from, to) = Rules.pointed(village, arrows, s);
      if (to == place) into++;
      if (from == place) outof++;
    }
    return into == 0 || outof == 0;
  }

  /// The places that cannot be reached from [from].
  List<int> lost(int from) {
    final got = Rules.reaches(village, arrows, from);
    return [
      for (var p = 0; p < village.placeCount; p++)
        if (!got.contains(p)) p,
    ];
  }

  /// Turns street [which] about.
  Play turn(int which) {
    if (isOver || which < 0 || which >= village.streetCount) return this;
    final next = List.of(arrows)..[which] = !arrows[which];
    final nowSeen = Rules.pairs(village, next) == level.bestPairs
        ? {...seen, next.map((way) => way ? '1' : '0').join()}
        : seen;
    return Play._(
      level: level,
      arrows: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(arrows);

  /// A hopeless ask, admitted: [enough] orientations found that got as
  /// far as the village allows, or [gaveUpAt] turns gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The street the pointer names: the first one pointing away from the
  /// nearest orientation that lands the ask, or null when there is
  /// nothing to point at.
  int? get next {
    if (isOver) return null;
    final near = Rules.nearest(village, arrows);
    if (near == null) return null;
    final (want, _) = near;
    for (var s = 0; s < village.streetCount; s++) {
      if (want[s] != arrows[s]) return s;
    }
    return null;
  }

  /// How many turns the nearest answer is away, or null when there is
  /// none.
  int? get away => Rules.nearest(village, arrows)?.$2;

  /// The pointer's words.
  String pointed(int street) =>
      'Turn the street between ${Rules.tellPlace(village.streets[street].$1)} '
      'and ${Rules.tellPlace(village.streets[street].$2)} about.';
}

/// Why a bridge cannot be pointed either way: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Every street of the village is to be made one-way, and the ask is '
      'that every place can still be reached from every other. Robbins\' '
      'theorem, from Herbert Robbins in 1939, says which villages can take '
      'it: a joined village can be made one-way throughout exactly when no '
      'street is a bridge, a street whose closing would cut the village in '
      'two. One way round the argument is easy to see. Point a bridge and '
      'the side it leaves can never be got back to, so a village with a '
      'bridge is out. The other way is the work of the theorem: build the '
      'village up from one round trip at a time and every new stretch can be '
      'pointed the way it was walked.\n\n'
      'The sham counts the orientations that work twice over. It tries every '
      'one of them, ${play.village.orientations} for ${play.village.name}, '
      'and it works the same count out of the village\'s Tutte polynomial at '
      '(0, 2), which never points a street at all. The two agree on all five '
      'villages, and on the toll lane both give nought.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every orientation of every '
      'street, tried in full.';
}
