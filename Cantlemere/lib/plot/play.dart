import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the plots laid so far, the pegs a hand is resting
/// on, the taps counted, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.laid,
    required this.holding,
    required this.taps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : laid = const [],
        holding = const [],
        taps = 0,
        seen = const {},
        before = null;

  /// A go with plots already down and no taps counted: what the mark
  /// draws, and what the field shows once it has admitted an ask.
  const Play.cut(this.level, this.laid)
      : holding = const [],
        taps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The plots on the field, by their number among all the plots the
  /// pegs allow.
  final List<int> laid;

  /// The pegs tapped since the last plot went down, at most two of them.
  final List<int> holding;

  final int taps;

  /// The cuts tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the field admits it.
  static const gaveUpAt = 24;

  /// The cuts a hopeless ask lets the player try before the field admits
  /// it.
  static const enough = 6;

  /// The plots themselves, corner by corner.
  List<List<int>> get pieces => [for (final p in laid) Rules.plots[p]];

  /// The half acres laid so far.
  int get taken {
    var n = 0;
    for (final p in laid) {
      n += Rules.halves(Rules.plots[p]);
    }
    return n;
  }

  int get left => Rules.field - taken;

  /// The plots that wear all three colours.
  List<int> get motley => [
        for (final p in laid)
          if (Rules.motley(Rules.plots[p])) p,
      ];

  /// The sizes of the laid plots, in half acres.
  List<int> get sizes => [for (final p in laid) Rules.halves(Rules.plots[p])];

  /// Whether a plot may be laid on these three pegs: it has to enclose
  /// something and lie clear of everything already down.
  bool canLay(List<int> corners) {
    if (Rules.halves(corners) == 0) return false;
    for (final p in laid) {
      if (!Rules.apart(Rules.plots[p], corners)) return false;
    }
    return true;
  }

  /// Which plot a set of three pegs is, or null when they make none.
  int? plotOf(List<int> corners) {
    final want = [...corners]..sort();
    for (var i = 0; i < Rules.plots.length; i++) {
      final p = Rules.plots[i];
      if (p[0] == want[0] && p[1] == want[1] && p[2] == want[2]) return i;
    }
    return null;
  }

  String get mark => (([...laid])..sort()).join(',');

  /// Taps a peg. Two pegs rest under the hand; the third lays the plot
  /// if it can be laid.
  Play tap(int peg) {
    if (isOver || peg < 0 || peg >= Rules.pegs) return this;
    if (holding.contains(peg)) {
      // Tapping a peg already under the hand takes it back off.
      return Play._(
        level: level,
        laid: laid,
        holding: [for (final h in holding) if (h != peg) h],
        taps: taps + 1,
        seen: seen,
        before: before,
      );
    }
    if (holding.length < 2) {
      return Play._(
        level: level,
        laid: laid,
        holding: [...holding, peg],
        taps: taps + 1,
        seen: seen,
        before: before,
      );
    }
    final corners = [...holding, peg];
    if (!canLay(corners)) return this;
    final which = plotOf(corners);
    if (which == null) return this;
    final to = [...laid, which];
    final at = (([...to])..sort()).join(',');
    return Play._(
      level: level,
      laid: to,
      holding: const [],
      taps: taps + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Lifts a laid plot off the field again.
  Play lift(int plot) {
    if (isOver || !laid.contains(plot)) return this;
    return Play._(
      level: level,
      laid: [for (final p in laid) if (p != plot) p],
      holding: const [],
      taps: taps,
      seen: seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(laid);

  /// A hopeless ask, admitted: [enough] cuts tried, or [gaveUpAt] taps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || taps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every cut that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) => _winners.putIfAbsent(
      level.name, () => Rules.cutsOf(level.pieces, even: level.even));

  /// A winning cut that keeps every plot already laid, or null when
  /// nothing already down can be part of one.
  List<int>? get carryOn {
    for (final win in winners(level)) {
      var holds = true;
      for (final p in laid) {
        if (!win.contains(p)) {
          holds = false;
          break;
        }
      }
      if (!holds) continue;
      // The pegs under the hand have to belong to a plot still wanted.
      if (holding.isEmpty) return win;
      for (final p in win) {
        if (laid.contains(p)) continue;
        final corners = Rules.plots[p];
        var fits = true;
        for (final h in holding) {
          if (!corners.contains(h)) fits = false;
        }
        if (fits) return win;
      }
    }
    return null;
  }

  /// What the pointer says: the peg to tap next. Null when nothing on
  /// the field can be carried on with.
  int? get next {
    if (isOver) return null;
    final win = carryOn;
    if (win == null) return null;
    for (final p in win) {
      if (laid.contains(p)) continue;
      final corners = Rules.plots[p];
      if (holding.isEmpty || holding.every(corners.contains)) {
        for (final c in corners) {
          if (!holding.contains(c)) return c;
        }
      }
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int peg) {
    final (x, y) = Rules.peg(peg);
    final more = 2 - holding.length;
    return 'Tap the peg at $x, $y'
        '${more > 0 ? ', then $more more to lay the plot.' : ' to lay the plot.'}';
  }

  /// A three-plot cut of the field, kept as near to what the player laid
  /// as it can be. Every one of them fails the last ask, so it is the
  /// picture to argue over once the field has admitted it.
  Play get asThree {
    final three = Rules.cutsOf(3);
    var best = three.first;
    var shared = -1;
    for (final cut in three) {
      var n = 0;
      for (final p in cut) {
        if (laid.contains(p)) n++;
      }
      if (n > shared) {
        shared = n;
        best = cut;
      }
    }
    return Play.cut(level, best);
  }
}

/// Why three equal plots are not to be had: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The field is three across and nine acres, with a peg at every '
      'whole point. Tap three pegs and the plot they make is laid, so long '
      'as it encloses something and lies clear of the plots already down. '
      'Sizes are counted in half acres so that every one of them is a whole '
      'number, and the field is 18.\n\n'
      'Two equal plots are easy: cut along either diagonal and both come to '
      '9. Six equal plots of 3 can be had 68 ways. Three equal plots of 6 '
      'cannot be had at all, and neither can any other odd number of equal '
      'plots. Monsky proved that in 1970, for every cut of a square and not '
      'only for cuts with corners on pegs.\n\n'
      'On this field it can be seen without the proof, twice. The first way '
      'is a count: every one of the 32 ways of cutting the field into three '
      'plots comes out 3, 6 and 9 half acres, because a cut into three '
      'always leaves one plot standing on a whole side, and a whole side is '
      'half the field. Half is not a third.\n\n'
      'The second way is Monsky\'s own, and it goes further. Give every peg '
      'a colour taken from its own two numbers: red where both are even, '
      'blue where the across number is odd, green where the across number '
      'is even and the up number odd. Walk the rim and count the steps '
      'between red and blue: there are three of them, an odd number, so '
      'somewhere inside the field there has to be a plot wearing all three '
      'colours. Call it motley. Work out the size of any motley plot and it '
      'always comes out odd, on every one of the 128 the pegs allow. Three '
      'equal plots would each be 6, and 6 is not odd.\n\n'
      'The field never asserts what it has not computed. Every way of '
      'cutting it into plots was walked before the bake, all 26,822,326 of '
      'them, and not one has an even number of motley plots. The cuts were '
      'counted twice over besides: once by laying plots over the 624 cells '
      'the pegs\' own lines cut the field into, and once by asking only that '
      'no two plots overlap and that the sizes come to 18.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
