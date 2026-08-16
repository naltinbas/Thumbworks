import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the pegs set in order, the taps taken, the fours
/// finished, and the go before, so a tap can be taken back.
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

  /// A go standing at four pegs, no taps counted: what the mark draws.
  Play.standing(this.level, this.pegs)
      : moves = 0,
        tried = 0,
        before = null;

  final Level level;

  /// The pegs set, in order: four at most.
  final List<Peg> pegs;

  /// The taps taken.
  final int moves;

  /// How many fours have been finished.
  final int tried;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never finishes three fours.
  static const gaveUpAt = 20;

  /// The fours a hopeless ask lets the player finish before the sham
  /// admits it.
  static const enough = 3;

  static const names = ['A', 'B', 'C', 'D'];

  bool get full => pegs.length == 4;

  bool get threeInLine => full && Rules.threeInLine(pegs);

  List<Point2> get centres => Rules.centres(pegs.length >= 2 ? pegs : const []);

  /// The centres of the squares on the sides set so far, doubled.
  List<Point2> get centresSoFar => [for (var i = 0; i + 1 < pegs.length; i++) Rules.centre(pegs[i], pegs[i + 1]), if (full) Rules.centre(pegs[3], pegs[0])];

  (Frac, Frac)? get lengthsSquared => full ? Rules.lengthsSquared(pegs) : null;

  bool get sameLength => full && Rules.sameLength(pegs);

  bool get atRightAngles => full && Rules.atRightAngles(pegs);

  /// The second voice's word: the first join turned is the second.
  bool get turnedIsTheOther => full && Rules.turnedIsTheOther(pegs);

  (Frac, Frac)? get crossing => full ? Rules.crossing(pegs) : null;

  bool get centresMakeSquare => full && Rules.centresMakeSquare(pegs);

  bool get centresWhole => full && Rules.centresWhole(pegs);

  /// A tap on peg [p]: lifts the last peg when it is that one, else sets
  /// the next peg when there is room and the peg is free.
  Play tap(Peg p) {
    if (isOver || !Rules.onBoard(p)) return this;
    if (pegs.isNotEmpty && pegs.last == p) {
      return Play._(level: level, pegs: pegs.sublist(0, pegs.length - 1), moves: moves + 1, tried: tried, before: this);
    }
    if (full || pegs.contains(p)) return this;
    final next = [...pegs, p];
    return Play._(level: level, pegs: next, moves: moves + 1, tried: tried + (next.length == 4 ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(pegs);

  /// A hopeless ask, admitted: [enough] fours finished, each with its
  /// two joins equal and square, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (tried >= enough && full || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, lift), the last peg lifted when it is
  /// astray from the aim, else the aim's next peg set; null when there
  /// is nothing to point at.
  (Peg, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < pegs.length; i++) {
      if (pegs[i] != aim[i]) return (pegs.last, true);
    }
    return pegs.length < 4 ? (aim[pegs.length], false) : null;
  }

  /// The pointer's words.
  static String pointed((Peg, bool) aim) => '${aim.$2 ? 'Lift' : 'Set'} the peg at ${Rules.tellPeg(aim.$1)}.';
}

/// Why the joins are always equal and square: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Set four pegs in order, A, B, C and D, and build a square outward '
      'on every side. Join the centre of the square on AB to the centre of '
      'the square on CD, and the centre on BC to the centre on DA: the two '
      'joins are of one length and cross at right angles, whatever the four '
      'pegs, convex, dented or crossed over. Van Aubel proved it in 1878. '
      'Each centre is the two ends of its side added and their gap turned a '
      'right angle, halved; write the join from the first centre to the '
      'third out from the four pegs and turn it a right angle, and it comes '
      'out as the join from the second to the fourth, letter for letter, '
      'which is the whole of the proof. And when the four pegs are a '
      'parallelogram the four centres make a square, as Thebault added in '
      '1937.\n\n'
      'The game takes every ordered four of pegs on the five-by-five board, '
      '303,600, finds the four centres of each and reads the two joins\' '
      'lengths and their angle off them, then works the turned join out from '
      'the pegs alone and finds it the other join on every four; on the '
      '227,952 fours with no three pegs in a line it counts the asks, and '
      'the joins are equal and square on every one of the 303,600.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every four of pegs on the board, '
      'squared in full.';
}
