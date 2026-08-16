import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the pegs set so far, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.chosen,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : chosen = const [],
        moves = 0,
        before = null;

  /// A go standing at four pegs, no taps counted: what the mark draws.
  Play.standing(this.level, this.chosen)
      : moves = 0,
        before = null;

  final Level level;

  /// The pegs set, by index into [Rules.pegs], in the order tapped: the
  /// first two make one chord, the next two the other.
  final List<int> chosen;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never gets two chords to cross.
  static const gaveUpAt = 20;

  Peg peg(int k) => Rules.pegs[chosen[k]];

  /// The first chord's ends, or null before it is whole.
  (Peg, Peg)? get first => chosen.length >= 2 ? (peg(0), peg(1)) : null;

  /// The second chord's ends, or null before it is whole.
  (Peg, Peg)? get second => chosen.length >= 4 ? (peg(2), peg(3)) : null;

  /// Where the two chords cross inside the wheel, or null.
  Point? get crossing => second == null ? null : Rules.crossing(peg(0), peg(1), peg(2), peg(3));

  /// The two products of pieces, or null.
  (Frac, Frac)? get products {
    final p = crossing;
    if (p == null) return null;
    return (Rules.product(p, peg(0), peg(1)), Rules.product(p, peg(2), peg(3)));
  }

  /// The power of the crossing, the second voice, or null.
  Frac? get power => crossing == null ? null : Rules.power(crossing!);

  /// A tap on peg [i]: lifts it if set, sets it if there is room, else
  /// nothing.
  Play tap(int i) {
    if (isOver || i < 0 || i >= Rules.pegs.length) return this;
    final c = List.of(chosen);
    if (c.contains(i)) {
      c.remove(i);
    } else if (c.length < 4) {
      c.add(i);
    } else {
      return this;
    }
    return Play._(level: level, chosen: c, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && chosen.length == 4 && level.meets(peg(0), peg(1), peg(2), peg(3));

  /// A hopeless ask, admitted: two chords cross, and their products are
  /// what they must be, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (crossing != null || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (peg, lift), the pegs set that stray from
  /// the aim's order lifted last first, then the aim's next peg set; null
  /// when there is nothing to point at.
  (int, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var k = 0; k < chosen.length; k++) {
      if (chosen[k] != aim[k]) return (chosen.last, true);
    }
    return chosen.length < 4 ? (aim[chosen.length], false) : null;
  }

  /// The pointer's words.
  static String pointed((int, bool) aim) => '${aim.$2 ? 'Lift' : 'Set'} the peg at ${Rules.tellPeg(Rules.pegs[aim.$1])}.';
}

/// Why the two products agree: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two chords of a circle cross at a point P, and each is cut into two '
      'pieces: the pieces of the one multiply to the same amount as the pieces '
      'of the other, PA times PB is PC times PD. Euclid has it, the '
      'thirty-fifth of his third book: join A to C and B to D, and the '
      'triangles PAC and PDB have the same angles, since the angles at A and D '
      'stand on the same arc, so their sides are in proportion. The amount is '
      'the power of the point, the radius squared less its distance from the '
      'middle squared, so a crossing at the middle gives 25 and one near the '
      'rim gives little.\n\n'
      'The wheel here has twelve pegs, every whole point on the circle of '
      'radius five, and 66 chords between them; every four pegs give one pair '
      'of chords that cross, 495 crossings, and the game works every crossing '
      'as an exact point and every product of pieces exactly, never as a '
      'decimal, then again as 25 less the crossing\'s distance from the middle '
      'squared. The two agree on all 495.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every crossing of the wheel\'s '
      'chords, worked in full.';
}
