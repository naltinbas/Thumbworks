import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two rings of stones, the taps so far, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.dark,
    required this.pale,
    required this.taps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : dark = Rules.opening.$1,
        pale = Rules.opening.$2,
        taps = 0,
        seen = const {},
        before = null;

  /// A go laid out as it stands, no taps counted: what the mark draws.
  const Play.laid(this.level, this.dark, this.pale)
      : taps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The holes holding a dark stone, as a bitmask.
  final int dark;

  /// The holes holding a pale stone.
  final int pale;

  final int taps;

  /// The boards tried on a hopeless ask.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the hoop admits it.
  static const gaveUpAt = 20;

  /// The boards a hopeless ask lets the player try before the hoop
  /// admits it.
  static const enough = 8;

  (int, int) get board => (dark, pale);

  /// The holes whose lamps are lit.
  int get lamps => Rules.lamps(dark, pale);

  int get darkCount => Rules.count(dark);
  int get paleCount => Rules.count(pale);
  int get lampCount => Rules.count(lamps);

  /// The fewest lamps these stone counts could ever leave.
  int get floor => Rules.floor(darkCount, paleCount);

  /// How many ways each hole is lit, which the piling voice cannot see.
  List<int> get ways => Rules.ways(dark, pale);

  /// Puts a stone in a hole or takes it out. [ring] is 0 for dark and 1
  /// for pale.
  Play tap(int ring, int hole) {
    if (isOver || hole < 0 || hole >= Rules.holes) return this;
    final toDark = ring == 0 ? dark ^ (1 << hole) : dark;
    final toPale = ring == 1 ? pale ^ (1 << hole) : pale;
    return Play._(
      level: level,
      dark: toDark,
      pale: toPale,
      taps: taps + 1,
      seen: !level.winnable ? {...seen, toDark << Rules.holes | toPale} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(board);

  /// A hopeless ask, admitted: [enough] boards tried, or [gaveUpAt]
  /// taps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || taps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every board that lands the ask, worked out once per ask.
  static final Map<String, List<(int, int)>> _winners = {};

  static List<(int, int)> winners(Level level) =>
      _winners.putIfAbsent(level.name, () {
        final out = <(int, int)>[];
        for (var a = 0; a < 1 << Rules.holes; a++) {
          if (Rules.count(a) != level.dark) continue;
          for (var b = 0; b < 1 << Rules.holes; b++) {
            if (level.meets((a, b))) out.add((a, b));
          }
        }
        return out;
      });

  /// The nearest board that lands the ask, and the taps to it.
  ((int, int), int)? get nearest {
    (int, int)? best;
    var away = -1;
    for (final win in winners(level)) {
      final n = Rules.between(board, win);
      if (away < 0 || n < away) {
        away = n;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the ring and the hole to tap. Null when
  /// there is nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // Every hole that differs is one tap and one step nearer, so the
    // first will do.
    for (var h = 0; h < Rules.holes; h++) {
      if (dark >> h & 1 != near.$1.$1 >> h & 1) return (0, h);
    }
    for (var h = 0; h < Rules.holes; h++) {
      if (pale >> h & 1 != near.$1.$2 >> h & 1) return (1, h);
    }
    return null;
  }

  /// The pointer's words.
  String pointed((int, int) aim) {
    final ring = aim.$1 == 0 ? 'dark' : 'pale';
    final has = (aim.$1 == 0 ? dark : pale) >> aim.$2 & 1 == 1;
    return has
        ? 'Take the $ring stone out of hole ${aim.$2}.'
        : 'Put a $ring stone in hole ${aim.$2}.';
  }

  /// The board nearest this one that carries the stones the ask calls
  /// for. Every board of that shape fails the hopeless ask, so this is
  /// only the picture to argue over: it is where the walk is drawn once
  /// the hoop has admitted it cannot be done.
  Play get asAsked {
    if (level.meets(board) ||
        (darkCount == level.dark && paleCount == level.pale)) {
      return Play.laid(level, dark, pale);
    }
    var best = (0, 0);
    var away = -1;
    for (var a = 0; a < 1 << Rules.holes; a++) {
      if (Rules.count(a) != level.dark) continue;
      for (var b = 0; b < 1 << Rules.holes; b++) {
        if (Rules.count(b) != level.pale) continue;
        final n = Rules.between(board, (a, b));
        if (away < 0 || n < away) {
          away = n;
          best = (a, b);
        }
      }
    }
    return Play.laid(level, best.$1, best.$2);
  }

  /// The step the finger proof walks, which is the gap between the two
  /// dark stones. Only meant for a board holding exactly two of them.
  int get step => darkCount == 2 ? Rules.step(dark) : 0;

  /// The holes in the order that walk visits them.
  List<int> get walk => darkCount == 2 ? Rules.walk(dark) : const [];

  /// The last pale stone of each run along the walk. Each one costs a
  /// lamp of its own.
  List<int> get runEnds => darkCount == 2 ? Rules.ends(dark, pale) : const [];
}

/// Why the lamps never fall below the floor: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Seven holes round a hoop, numbered 0 to 6, and counting past 6 '
      'comes back to 0. Lay dark stones in some holes and pale stones in '
      'some holes. A lamp at a hole lights when that hole is a dark hole '
      'plus a pale hole.\n\n'
      'Tapping is the proof of one half. Every dark stone lays the whole '
      'pale ring down again, turned round the hoop by that stone\'s hole, '
      'and the lamps are all those copies piled up. Add a dark stone and '
      'one more copy goes down; move a pale stone and every copy moves '
      'with it.\n\n'
      'The other half is the floor. However the stones are laid, the lamps '
      'come to at least the two stone counts added with one taken off, or '
      'the whole hoop if that is fewer. Cauchy proved it in 1813. Davenport '
      'proved it again in 1935 without knowing, and found Cauchy\'s proof '
      'in 1947.\n\n'
      'Seven being a prime is the whole of it. Pick any two dark stones and '
      'step round the hoop by the gap between them. Because seven has no '
      'divisor but itself and one, that step visits every hole before it '
      'comes back. Walk the pale stones in that order and they fall into '
      'runs, and the hole one step past the end of a run lights without '
      'holding a pale stone of its own. So the lamps come to the pale '
      'stones plus the number of runs, and there is always at least one '
      'run. On a hoop of six holes a step of two or three goes round only '
      'part of the way, the walk closes early, and the floor gives out: two '
      'dark stones and four pale leave four lamps there, nine boards over.'
      '\n\n'
      'The hoop counts everything twice before it says it. One voice piles '
      'the turned copies up. The other multiplies the rings out hole by '
      'hole, so it knows how many ways each lamp is lit and not merely that '
      'it is, and its counts add up to the two stone counts multiplied. A '
      'third voice lights nothing at all and reads the floor off the '
      'divisors of the hoop. All three were run over every one of the '
      '16,384 boards seven holes allow.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
