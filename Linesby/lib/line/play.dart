import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three pegs, the one lifted if any, the moves
/// taken, and the go before, so a move can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.pegs,
    required this.held,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : pegs = opening,
        held = null,
        moves = 0,
        before = null;

  /// A go standing at a triangle, no moves counted: what the mark draws.
  Play.standing(this.level, this.pegs)
      : held = null,
        moves = 0,
        before = null;

  final Level level;

  /// The pegs A, B and C, in that order.
  final List<Peg> pegs;

  /// The peg lifted, 0 to 2, or null when none is.
  final int? held;

  /// The moves taken: a move is a peg set down somewhere new.
  final int moves;

  final Play? before;

  /// Where every ask opens.
  static const opening = <Peg>[(1, 1), (5, 2), (2, 4)];

  /// The moves a hopeless ask runs to before the sham admits it, if the
  /// player never gets as near as the field allows.
  static const gaveUpAt = 12;

  static const names = ['A', 'B', 'C'];

  Peg get a => pegs[0];
  Peg get b => pegs[1];
  Peg get c => pegs[2];

  Centre get centroid => Rules.centroid(a, b, c);
  Centre get circumcentre => Rules.circumcentre(a, b, c);
  Centre get orthocentre => Rules.orthocentre(a, b, c);
  String get kind => Rules.kind(a, b, c);
  List<int> get sides => Rules.sides(a, b, c);

  /// Where the circumcentre stands: 'inside', 'on the edge', 'outside'
  /// or 'off the field'.
  String get whereO => Rules.onField(circumcentre) ? Rules.where(circumcentre, a, b, c) : 'off the field';

  /// A tap on peg [p] of the field: lifts the peg there, sets the lifted
  /// peg down there, or does nothing. Setting a peg down where it makes
  /// a line of the three is refused, and that is not a move.
  Play tap(Peg p) {
    if (isOver) return this;
    final at = pegs.indexOf(p);
    final h = held;
    if (h == null) {
      return at < 0 ? this : _with(held: at);
    }
    if (at == h) return _with(held: null);
    if (at >= 0) return _with(held: at);
    final moved = List.of(pegs)..[h] = p;
    if (Rules.inLine(moved[0], moved[1], moved[2])) return this;
    return Play._(level: level, pegs: moved, held: null, moves: moves + 1, before: this);
  }

  Play _with({required int? held}) => Play._(level: level, pegs: pegs, held: held, moves: moves, before: this);

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(a, b, c);

  /// A hopeless ask, admitted: the triangle is as near to equilateral as
  /// the field comes, or [gaveUpAt] moves are gone.
  bool get gaveUp => !level.winnable && (Rules.spread(a, b, c) == Rules.nearest || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, where to set it), towards the aim
  /// with the fewest moves, never through a line of three; null when
  /// there is nothing to point at.
  (int, Peg)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final targets = [aim.$1, aim.$2, aim.$3];
    (int, Peg)? best;
    var fewest = 4;
    for (final order in const [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]) {
      // Peg i goes to targets[order[i]].
      final away = [for (var i = 0; i < 3; i++) if (pegs[i] != targets[order[i]]) i];
      if (away.length >= fewest) continue;
      for (final i in away) {
        final moved = List.of(pegs)..[i] = targets[order[i]];
        if (!Rules.inLine(moved[0], moved[1], moved[2])) {
          fewest = away.length;
          best = (i, targets[order[i]]);
          break;
        }
      }
    }
    return best;
  }

  /// The pointer's words.
  static String pointed((int, Peg) aim) => 'Move peg ${names[aim.$1]} to ${Rules.tellPeg(aim.$2)}.';
}

/// Why the three centres keep to one line: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A triangle has a centroid, where its medians cross, a circumcentre, '
      'the middle of the circle through its corners, and an orthocentre, '
      'where its altitudes cross. Euler showed in 1765 that the three lie on '
      'one line, with the centroid a third of the way from the circumcentre '
      'to the orthocentre, so that H = A + B + C - 2O with O the circumcentre: '
      'the Euler line. In a right triangle the orthocentre is the right '
      'corner and the circumcentre the middle of the side across; in an '
      'equilateral one all three are one point, and only there.\n\n'
      'The game keeps every centre as an exact fraction and sweeps every '
      'triangle on the seven-by-seven field, 17,600 of them, three pegs not '
      'in a line, working the circumcentre from the equal distances and the '
      'orthocentre from the altitudes, then again from A + B + C - 2O; the '
      'two agree on all 17,600, the three centres lie in a line on all '
      '17,600 with the orthocentre twice as far from the centroid, and the '
      'nine-point centre sits halfway from O to H on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every triangle of the field, '
      'worked exactly.';
}
