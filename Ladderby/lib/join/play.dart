import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the pegs picked on each rail in order, the taps
/// taken, the hexagons tried, and the go before, so a tap can be taken
/// back.
class Play {
  const Play._({
    required this.level,
    required this.bottom,
    required this.top,
    required this.moves,
    required this.tried,
    required this.before,
  });

  Play.of(this.level)
      : bottom = const [],
        top = const [],
        moves = 0,
        tried = 0,
        before = null;

  /// A go standing at a hexagon, no taps counted: what the mark draws.
  Play.standing(this.level, this.bottom, this.top)
      : moves = 0,
        tried = 0,
        before = null;

  final Level level;

  /// The bottom pegs picked, in order: A, B, C.
  final List<int> bottom;

  /// The top pegs picked, in order: a, b, c.
  final List<int> top;

  /// The taps taken.
  final int moves;

  /// How many whole hexagons with all three crossings have been set.
  final int tried;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never sets three hexagons.
  static const gaveUpAt = 18;

  /// The hexagons a hopeless ask lets the player set before the sham
  /// admits it.
  static const enough = 3;

  static const bottomNames = ['A', 'B', 'C'], topNames = ['a', 'b', 'c'];

  bool get whole => bottom.length == 3 && top.length == 3;

  /// The three crossings, or null when the hexagon is not whole or a
  /// pair of joins runs parallel.
  (Point, Point, Point)? get crossings => whole ? Rules.crossings(bottom, top) : null;

  /// The crossings by the closed form, the second voice.
  (Point, Point, Point)? get crossingsByForm => whole ? Rules.crossingsByForm(bottom, top) : null;

  bool get inLine {
    final c = crossings;
    return c != null && Rules.inLine(c.$1, c.$2, c.$3);
  }

  /// Which pair of joins runs parallel, when the hexagon is whole but a
  /// crossing is missing: 'A-b with a-B', 'A-c with a-C' or 'B-c with b-C'.
  String? get parallel {
    if (!whole || crossings != null) return null;
    if (Rules.crossing(bottom[0], top[1], bottom[1], top[0]) == null) return 'A-b with a-B';
    if (Rules.crossing(bottom[0], top[2], bottom[2], top[0]) == null) return 'A-c with a-C';
    return 'B-c with b-C';
  }

  /// A tap on peg [p]: lifts it if picked, picks it if its rail has
  /// room, else nothing.
  Play tap(Peg p) {
    if (isOver) return this;
    final rail = p.$1, x = p.$2;
    if (rail < 0 || rail > 1 || x < 0 || x > Rules.last) return this;
    final list = List.of(rail == 0 ? bottom : top);
    if (list.contains(x)) {
      list.remove(x);
    } else if (list.length < 3) {
      list.add(x);
    } else {
      return this;
    }
    final b = rail == 0 ? list : bottom, t = rail == 1 ? list : top;
    final nowWhole = b.length == 3 && t.length == 3 && Rules.crossings(b, t) != null;
    return Play._(level: level, bottom: b, top: t, moves: moves + 1, tried: tried + (nowWhole ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && whole && level.meets(bottom, top);

  /// A hopeless ask, admitted: [enough] hexagons have been set and lain
  /// in a line, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (tried >= enough && crossings != null || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, lift), a picked peg astray from the
  /// aim's order lifted first, then the aim's next peg set, bottom rail
  /// first; null when there is nothing to point at.
  (Peg, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var k = 0; k < bottom.length; k++) {
      if (bottom[k] != aim.$1[k]) return ((0, bottom.last), true);
    }
    for (var k = 0; k < top.length; k++) {
      if (top[k] != aim.$2[k]) return ((1, top.last), true);
    }
    if (bottom.length < 3) return ((0, aim.$1[bottom.length]), false);
    if (top.length < 3) return ((1, aim.$2[top.length]), false);
    return null;
  }

  /// The pointer's words.
  static String pointed((Peg, bool) aim) =>
      '${aim.$2 ? 'Lift' : 'Set'} peg ${aim.$1.$2} on the ${aim.$1.$1 == 0 ? 'bottom' : 'top'} rail.';
}

/// Why the three crossings keep to a line: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Take three pegs A, B, C on one rail and three, a, b, c, on another, '
      'and draw the six cross-joins, A to b and a to B, A to c and a to C, B '
      'to c and b to C. Each pair crosses at a point, and the three points '
      'lie on one line, whatever pegs you picked. Pappus of Alexandria proved '
      'it around the year 340, and it is the oldest theorem of the kind that '
      'cares only about points and lines, not lengths or angles: Hilbert '
      'took it, in 1899, as one of the foundation stones of geometry. On '
      'these rails, which run parallel, a join and its swap cross at a '
      'height that is the height of the rails times one gap over the sum of '
      'two, and the three heights and reaches come out in a line by the '
      'same arithmetic every time.\n\n'
      'The game takes every ordering of three pegs on each rail, 112,896, '
      'finds where the cross-joins cross by the general meeting of two lines '
      'and again by the closed form for parallel rails, and checks the three '
      'crossings for a line; the two forms agree on all 85,008 orderings '
      'whose joins all cross, and the crossings lie in a line on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every hexagon on the rails, '
      'crossed in full.';
}
