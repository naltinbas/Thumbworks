import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the pegs set, the casts on their dials, the taps
/// taken, the whole settings tried, and the go before, so a tap can be
/// taken back.
class Play {
  const Play._({
    required this.level,
    required this.pegs,
    required this.casts,
    required this.moves,
    required this.tried,
    required this.before,
  });

  Play.of(this.level)
      : pegs = const [],
        casts = const [2, 2, 2],
        moves = 0,
        tried = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.pegs, this.casts)
      : moves = 0,
        tried = 0,
        before = null;

  final Level level;

  /// The pegs set, in order: three at most, A, B and C.
  final List<Peg> pegs;

  /// What each peg's shadow is cast at.
  final List<int> casts;

  /// The taps taken.
  final int moves;

  /// How many whole settings have been made.
  final int tried;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never finishes three settings.
  static const gaveUpAt = 24;

  /// The settings a hopeless ask lets the player finish before the sham
  /// admits it.
  static const enough = 3;

  static const names = ['A', 'B', 'C'];

  bool get full => pegs.length == 3;

  bool get flat => full && Rules.flat(pegs);

  /// Whether the three pegs make a triangle the lantern can cast.
  bool get sound => full && Rules.valid(pegs);

  /// The shadow pegs, one for each peg set.
  List<Peg> get shadows => [for (var i = 0; i < pegs.length; i++) Rules.shadow(pegs[i], casts[i])];

  /// The three meetings, or null when the triangle is not whole or is
  /// flat.
  List<Homo>? get meetings => sound ? Rules.meetings(pegs, casts) : null;

  bool get inLine {
    final m = meetings;
    return m != null && Rules.inLine(m);
  }

  Homo? get axis {
    final m = meetings;
    return m == null ? null : Rules.axis(m);
  }

  /// How many meetings run off to infinity.
  int get farOff {
    final m = meetings;
    return m == null ? 0 : m.where(Rules.atInfinity).length;
  }

  /// A tap on peg [p]: lifts the last peg when it is that one, else sets
  /// the next peg when there is room. A peg on the ray of one already
  /// set is refused: that side and its shadow would lie on one line.
  Play tap(Peg p) {
    if (isOver || !Rules.onField(p)) return this;
    if (pegs.isNotEmpty && pegs.last == p) {
      return Play._(level: level, pegs: pegs.sublist(0, pegs.length - 1), casts: casts, moves: moves + 1, tried: tried, before: this);
    }
    if (full || pegs.contains(p)) return this;
    if (pegs.any((q) => q.$1 * p.$2 - q.$2 * p.$1 == 0)) return this;
    final next = [...pegs, p];
    return Play._(level: level, pegs: next, casts: casts, moves: moves + 1, tried: tried + (next.length == 3 && Rules.valid(next) ? 1 : 0), before: this);
  }

  /// Steps the cast of peg [which], 0, 1 or 2, along the row of casts.
  Play step(int which, int by) {
    if (isOver || which < 0 || which > 2 || by == 0) return this;
    final at = Rules.casts.indexOf(casts[which]);
    final to = at + by;
    if (to < 0 || to >= Rules.casts.length) return this;
    final next = List.of(casts)..[which] = Rules.casts[to];
    return Play._(level: level, pegs: pegs, casts: next, moves: moves + 1, tried: tried + (sound ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && full && level.meets(pegs, casts);

  /// A hopeless ask, admitted: [enough] whole settings made, each with
  /// its meetings in a line, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (tried >= enough && sound || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('peg', i) to set the aim's ith peg, ('lift',
  /// i) to lift the last one, or ('cast', i) to step the ith cast on;
  /// null when there is nothing to point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < pegs.length; i++) {
      if (pegs[i] != aim.$1[i]) return ('lift', pegs.length - 1);
    }
    if (pegs.length < 3) return ('peg', pegs.length);
    for (var i = 0; i < 3; i++) {
      if (casts[i] != aim.$2[i]) return ('cast', i);
    }
    return null;
  }

  /// The peg the pointer wants set, or null.
  Peg? get wanted {
    final aim = level.aim;
    final n = next;
    if (aim == null || n == null || n.$1 != 'peg') return null;
    return aim.$1[n.$2];
  }

  /// Which way the pointer wants a cast stepped: 1 or -1.
  int castWay(int which) {
    final aim = level.aim;
    if (aim == null) return 1;
    return Rules.casts.indexOf(aim.$2[which]) > Rules.casts.indexOf(casts[which]) ? 1 : -1;
  }

  /// The pointer's words.
  String pointed((String, int) aim) {
    switch (aim.$1) {
      case 'peg':
        return 'Set peg ${names[aim.$2]} at ${Rules.tellPeg(wanted!)}.';
      case 'lift':
        return 'Lift peg ${names[aim.$2]}.';
      default:
        return 'Step ${names[aim.$2]}\'s cast ${castWay(aim.$2) > 0 ? 'out' : 'in'}.';
    }
  }
}

/// Why the three meetings keep to a line: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A lantern at the middle of a field, a triangle of three pegs about '
      'it, and a shadow triangle: each shadow peg lies along the ray from '
      'the lantern through its peg, at a whole multiple of the distance. Two '
      'triangles drawn from one point like that are said to be in '
      'perspective from it. Take matching sides in turn, AB with A\'B\', BC '
      'with B\'C\', CA with C\'A\', and mark where each pair meets: the three '
      'places lie on one line, the axis, whatever the pegs and whatever the '
      'multiples. Desargues proved it in 1639. Where two matching sides run '
      'parallel their meeting runs off to infinity, and the theorem holds '
      'there too, which is why it is stated in the projective plane, where a '
      'point at infinity is a point like any other and the far points make '
      'up a line of their own.\n\n'
      'The game takes every triangle of three pegs of the five-by-five field '
      'about the lantern and every cast of the three shadows, 729,600 '
      'settings, and finds the three meetings twice, once as homogeneous '
      'whole numbers by crossing the side-lines and once by solving the two '
      'lines as plain fractions; the two agree on all 511,488, and the three '
      'meetings lie on one line on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every triangle and every cast, '
      'crossed in full.';
}
