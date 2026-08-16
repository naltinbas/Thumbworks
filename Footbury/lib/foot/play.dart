import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three corners set on the rim, the point set,
/// the taps taken, the points tried off the rim, and the go before, so
/// a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.pegs,
    required this.moves,
    required this.tried,
    required this.before,
  });

  Play.of(this.level)
      : pegs = const [],
        moves = 0,
        tried = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, List<Peg> corners, Peg point)
      : pegs = [...corners, point],
        moves = 0,
        tried = 0,
        before = null;

  final Level level;

  /// The pegs set, in order: three corners on the rim, then the point.
  final List<Peg> pegs;

  /// The taps taken.
  final int moves;

  /// How many points off the rim have been set.
  final int tried;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never sets three points off the rim.
  static const gaveUpAt = 16;

  /// The points off the rim a hopeless ask lets the player set before
  /// the sham admits it.
  static const enough = 3;

  static const names = ['A', 'B', 'C', 'P'];

  List<Peg> get corners => pegs.length >= 3 ? pegs.sublist(0, 3) : pegs;

  Peg? get point => pegs.length == 4 ? pegs[3] : null;

  bool get full => pegs.length == 4;

  List<Point>? get feet => full ? Rules.feet(corners, point!) : null;

  Frac? get ratio => full ? Rules.ratioByFeet(corners, point!) : null;

  Frac? get ratioByEuler => full ? Rules.ratioByEuler(point!) : null;

  (Point, Point)? get line => full ? Rules.simsonLine(corners, point!) : null;

  bool get pointOnRim => point != null && Rules.onRim(point!);

  /// A tap on [p]: lifts the last peg when it is that one; sets a corner
  /// when fewer than three are set and p is a free rim peg; sets the
  /// point when three corners stand and p is a field point not a
  /// corner.
  Play tap(Peg p) {
    if (isOver || !Rules.inField(p)) return this;
    if (pegs.isNotEmpty && pegs.last == p) {
      return Play._(level: level, pegs: pegs.sublist(0, pegs.length - 1), moves: moves + 1, tried: tried, before: this);
    }
    if (pegs.length < 3) {
      if (!Rules.onRim(p) || pegs.contains(p)) return this;
      return Play._(level: level, pegs: [...pegs, p], moves: moves + 1, tried: tried, before: this);
    }
    if (full || pegs.contains(p)) return this;
    return Play._(level: level, pegs: [...pegs, p], moves: moves + 1, tried: tried + (Rules.onRim(p) ? 0 : 1), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && full && level.meets(corners, point!);

  /// A hopeless ask, admitted: [enough] points set off the rim, each
  /// with its feet apart, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (tried >= enough && full && !pointOnRim || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, lift), the last peg lifted when it is
  /// astray from the aim, else the aim's next peg set; null when there
  /// is nothing to point at.
  (Peg, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = [...aim.$1, aim.$2];
    for (var i = 0; i < pegs.length; i++) {
      if (pegs[i] != want[i]) return (pegs.last, true);
    }
    return pegs.length < 4 ? (want[pegs.length], false) : null;
  }

  /// The pointer's words.
  static String pointed((Peg, bool) aim, {int set = 0}) {
    if (aim.$2) return 'Lift the peg at ${Rules.tellPeg(aim.$1)}.';
    return set < 3 ? 'Set corner ${names[set]} at ${Rules.tellPeg(aim.$1)}.' : 'Set the point at ${Rules.tellPeg(aim.$1)}.';
  }
}

/// Why the feet line up on the rim and nowhere else: the words behind
/// the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A circle of radius five about the middle of a field of pegs, twelve '
      'pegs on its rim, and a triangle with its corners on the rim. From any '
      'point of the field drop a foot onto each of the three side-lines, '
      'the nearest point of the line. Wallace found in 1799, and the finding '
      'carries Simson\'s name, that the three feet lie in a line exactly when '
      'the point is on the circle. Euler had the measure of it in 1763: the '
      'triangle of the feet is to the big triangle as the square of the '
      'radius less the square of the point\'s distance from the middle is to '
      'four times the square of the radius, a quarter at the middle, nought '
      'on the rim, and the other way round outside.\n\n'
      'The game takes every triangle of three rim pegs, 220, and every point '
      'of the field but the corners, 118 each, 25,960 settings, drops the '
      'three feet exactly and measures their triangle against the whole, '
      'then measures it again by Euler\'s rule with no foot in sight; the two '
      'agree on all 25,960, and the feet lie in a line on the 1,980 rim '
      'settings and on none of the others.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every triangle on the rim with '
      'every point of the field, footed in full.';
}
