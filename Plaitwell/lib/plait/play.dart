import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: how the plait is painted, the taps made, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.paint,
    required this.taps,
    required this.seen,
    required this.before,
  });

  /// The opening: every arc the first colour, which keeps the rule at every
  /// crossing and uses one colour, so it lands nothing.
  Play.of(this.level)
      : paint = List.filled(level.arcs, 0),
        taps = 0,
        seen = const {},
        before = null;

  /// A plait painted as given and no taps counted: what the mark draws.
  const Play.painted(this.level, this.paint)
      : taps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The colour on each arc, nought, one or two.
  final List<int> paint;

  final int taps;

  /// The paintings tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the plait admits it.
  static const gaveUpAt = 20;

  /// The paintings a hopeless ask lets the player try before it admits it.
  static const enough = 8;

  String get mark => paint.join();

  /// The crossings this painting gets wrong.
  List<int> get wrong => Rules.wrong(level.crossings, paint);

  bool get allSound => wrong.isEmpty;

  /// How many colours are on the rope.
  int get shades => paint.toSet().length;

  /// Steps one arc on to the next colour.
  Play tap(int arc) {
    if (isOver || arc < 0 || arc >= paint.length) return this;
    final to = [...paint];
    to[arc] = (to[arc] + 1) % Rules.colours;
    return Play._(
      level: level,
      paint: to,
      taps: taps + 1,
      seen: !level.winnable ? {...seen, to.join()} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(paint);

  /// A hopeless ask, admitted: [enough] paintings tried, or [gaveUpAt] taps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || taps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every painting that lands the ask, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) => _winners.putIfAbsent(
      level.name, () => Rules.proper(level.crossings, level.arcs));

  /// The nearest painting that lands the ask, and the taps to it.
  (List<int>, int)? get nearest {
    List<int>? best;
    var away = -1;
    for (final win in winners(level)) {
      final n = Rules.between(paint, win);
      if (away < 0 || n < away) {
        away = n;
        best = win;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the arc to tap. Null when there is nothing to
  /// point at.
  int? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    for (var arc = 0; arc < paint.length; arc++) {
      if (paint[arc] != near.$1[arc]) return arc;
    }
    return null;
  }

  /// The letter written on an arc.
  static String letter(int arc) => String.fromCharCode(65 + arc);

  /// The pointer's words.
  String pointed(int arc) {
    final want = nearest!.$1[arc];
    final steps = (want - paint[arc]) % Rules.colours;
    return 'Rope ${letter(arc)} wants '
        '${steps == 1 ? 'one tap' : '$steps taps'}.';
  }
}

/// Why the painting count says what it says: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A plait of rope, crossed over and under and joined up at the '
      'ends. An arc is a length of rope that runs on over crossings and '
      'stops wherever the rope dives under. Paint the arcs in three '
      'colours, and keep one rule: at every crossing the three arc ends '
      'meeting there are all one colour or all three different.\n\n'
      'Painting the whole rope one colour always keeps the rule, so those '
      'three paintings tell you nothing and the ask is always for all '
      'three colours.\n\n'
      'Here is what makes the count worth having. Pull the rope about '
      'without cutting it and the picture changes, but the number of '
      'paintings does not. There are only three ways a picture of a knot '
      'can change: a kink is put in or taken out, two ropes are slid over '
      'each other and back, and a rope is slid across a crossing. Each of '
      'the three leaves the painting count where it was, and you can check '
      'that by eye on the pictures either side. So the count belongs to the '
      'knot rather than to the drawing.\n\n'
      'That is what makes it a proof rather than a puzzle. The trefoil has '
      '6 paintings in all three colours and the unknotted loop has none, so '
      'the trefoil cannot be pulled undone, however you go at it. The same '
      'goes for the figure eight, which also has none, so it is not the '
      'trefoil.\n\n'
      'The plait sweeps every painting of every ask, ${_all(level)} of them '
      'here, and counts what keeps the rule. It also takes each plait and '
      'works the three moves on it in every place they will go, checking the '
      'count never shifts.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}

String _all(Level level) {
  final n = level.allPaintings;
  return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
