import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which lanes are laid, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.village,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : village = Rules.opening,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a village, no taps counted: what the mark draws.
  Play.standing(this.level, this.village)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Which lanes are laid, a bit a lane.
  final int village;

  /// The taps taken.
  final int moves;

  /// The villages tried on a hopeless ask.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The villages a hopeless ask lets the player lay before the sham
  /// admits it.
  static const enough = 4;

  Map<int, Frac> get shares => Rules.shares(village);

  Frac get total => Rules.total(village);

  int get stringings => Rules.stringings(village).length;

  int get lanes => Rules.howMany(village);

  bool has(int lane) => Rules.has(village, lane);

  /// Whether lifting this lane would cut a green off.
  bool wouldCut(int lane) =>
      has(lane) && !Rules.joinedUp(Rules.toggle(village, lane));

  Play _to(int to) {
    final nowSeen = !level.winnable ? {...seen, to} : seen;
    return Play._(
      level: level,
      village: to,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Lays the lane if it is not there, lifts it if it is. A lift that
  /// would cut a green off is refused.
  Play tap(int lane) {
    if (isOver || lane < 0 || lane >= Rules.howManyLanes) return this;
    final to = Rules.toggle(village, lane);
    if (!Rules.joinedUp(to)) return this;
    return _to(to);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(village);

  /// A hopeless ask, admitted: [enough] villages tried, or [gaveUpAt]
  /// taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every village that lands the ask, worked out once per ask.
  static final Map<String, List<int>> _winners = {};

  static List<int> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        return [
          for (final village in Rules.villages())
            if (level.meets(village)) village,
        ];
      });

  /// The nearest village that lands the ask, and how many taps away it
  /// is.
  (int, int)? get nearest {
    int? best;
    var away = -1;
    for (final win in winners(level)) {
      final taps = Rules.taps(village, win);
      if (away < 0 || taps < away) {
        away = taps;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the lane to tap, and whether it is to be
  /// laid. Lanes the aim wants are laid first, which is why the pointer
  /// is never asked for a lift that would cut a green off.
  (int, bool)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    for (var lane = 0; lane < Rules.howManyLanes; lane++) {
      if (Rules.has(near.$1, lane) && !has(lane)) return (lane, true);
    }
    for (var lane = 0; lane < Rules.howManyLanes; lane++) {
      if (!Rules.has(near.$1, lane) && has(lane)) return (lane, false);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, bool) aim) => aim.$2
      ? 'Lay the lane from ${Rules.tellLane(aim.$1)}.'
      : 'Lift the lane from ${Rules.tellLane(aim.$1)}.';
}

/// Why the shares always add to four: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Five greens, and lanes laid between them as you like, so long as '
      'every green can be reached from every other. A stringing is a set of '
      'lanes that joins them all up with no loop in it, and it always takes '
      'four lanes: any fewer leaves a green cut off, any more closes a '
      'loop. A lane\'s share is the fraction of the village\'s stringings '
      'that run along it.\n\n'
      'Add the shares up and you always get four. Count it the other way '
      'round: each stringing contributes its four lanes, one to each of '
      'four shares, so the whole sum is four times the number of stringings '
      'divided by the number of stringings. The lanes can lie however they '
      'like and the total will not move.\n\n'
      'Ronald Foster published this in 1949 for electrical networks. Make '
      'every lane a one ohm wire and a lane\'s share is exactly the '
      'resistance the village offers between that lane\'s two ends, so the '
      'resistances across the wires of any connected network add to the '
      'number of '
      'nodes less one. The sham works every share twice: once by counting '
      'the stringings one at a time, and once by putting a unit of traffic '
      'in at one end of a lane and out at the other and reading the '
      'difference across it in exact fractions.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: all 728 villages that join '
      'their greens up, strung in full before the sham was built.';
}
