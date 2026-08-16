import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the pegs set, the taps taken, the lines tried, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.chosen,
    required this.moves,
    required this.tried,
    required this.before,
  });

  Play.of(this.level)
      : chosen = const [],
        moves = 0,
        tried = 0,
        before = null;

  /// A go standing at two pegs, no taps counted: what the mark draws.
  Play.standing(this.level, this.chosen)
      : moves = 0,
        tried = 0,
        before = null;

  final Level level;

  /// The pegs set, in the order tapped: two at most.
  final List<Peg> chosen;

  /// The taps taken.
  final int moves;

  /// How many lines crossing all three side-lines have been set.
  final int tried;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never sets three lines.
  static const gaveUpAt = 12;

  /// The lines a hopeless ask lets the player set before the sham
  /// admits it.
  static const enough = 3;

  Peg? get p => chosen.isEmpty ? null : chosen[0];
  Peg? get q => chosen.length < 2 ? null : chosen[1];

  /// Whether a line is set that crosses all three side-lines.
  bool get crosses => chosen.length == 2 && Rules.crossesAll(chosen[0], chosen[1]);

  (Point, Point, Point)? get crossings => crosses ? Rules.crossings(chosen[0], chosen[1]) : null;

  /// The ratios by the crossings, the first voice, or null.
  (Frac, Frac, Frac)? get ratios => crosses ? Rules.ratiosByCrossings(chosen[0], chosen[1]) : null;

  /// The ratios by the areas, the second voice, or null.
  (Frac, Frac, Frac)? get ratiosByAreas => crosses ? Rules.ratiosByAreas(chosen[0], chosen[1]) : null;

  int? get sidesInside => crosses ? Rules.sidesInside(chosen[0], chosen[1]) : null;

  /// Why a set line does not cross all three side-lines, or null.
  String? get flaw {
    if (chosen.length < 2 || crosses) return null;
    final (a, b) = (chosen[0], chosen[1]);
    final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
    if (dy == 0) return 'it runs level with AB and never meets it';
    if (dx == 0) return 'it runs up with CA and never meets it';
    if (dx + dy == 0) return 'it runs along with BC and never meets it';
    return 'it goes through a corner of the triangle';
  }

  /// A tap on peg [at]: lifts it if set, sets it if there is room, else
  /// nothing.
  Play tap(Peg at) {
    if (isOver) return this;
    final c = List.of(chosen);
    if (c.contains(at)) {
      c.remove(at);
    } else if (c.length < 2) {
      c.add(at);
    } else {
      return this;
    }
    final nowCrosses = c.length == 2 && Rules.crossesAll(c[0], c[1]);
    return Play._(level: level, chosen: c, moves: moves + 1, tried: tried + (nowCrosses ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && chosen.length == 2 && level.meets(chosen[0], chosen[1]);

  /// A hopeless ask, admitted: [enough] lines have been set and cut what
  /// they cut, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (tried >= enough && crosses || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, lift), a set peg astray from the aim
  /// lifted first, then the aim's next peg set; null when there is
  /// nothing to point at.
  (Peg, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final want = [aim.$1, aim.$2];
    for (var k = 0; k < chosen.length; k++) {
      if (chosen[k] != want[k]) return (chosen.last, true);
    }
    return chosen.length < 2 ? (want[chosen.length], false) : null;
  }

  /// The pointer's words.
  static String pointed((Peg, bool) aim) => '${aim.$2 ? 'Lift' : 'Set'} the peg at ${Rules.tellPeg(aim.$1)}.';
}

/// Why the ratios multiply to one, and why a line never cuts all three
/// sides inside: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Draw a straight line across a triangle ABC, and let it cut the '
      'side-lines AB, BC and CA at F, D and E. Menelaus of Alexandria showed, '
      'around the year 100, that the three ratios AF:FB, BD:DC and CE:EA '
      'multiply to one, counting a ratio negative when its cut falls outside '
      'the side: the product is -1, and an odd number of the cuts lie outside. '
      'The reason is distances: a line divides a side in the ratio of the '
      'ends\' distances from it, so the three ratios are the distances of A, '
      'B and C from the line taken round in a ring, and everything cancels '
      'but the sign. And a straight line that goes into a triangle at one '
      'side comes out at another and cannot come back for the third, so it '
      'cuts two sides inside or none.\n\n'
      'The game takes every line through two pegs of the thirteen-by-thirteen '
      'field that crosses all three side-lines, 6,140 lines, finds the three '
      'cuts exactly and reads the ratios off them, then reads the same ratios '
      'again from the corners\' distances to the line; the two agree on all '
      '6,140, the product is -1 on every one, and every line cuts two sides '
      'inside or none.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every line through two pegs of '
      'the field, cut in full.';
}
