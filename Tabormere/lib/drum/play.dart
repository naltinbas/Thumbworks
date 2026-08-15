import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { set, lift }

/// A rhythm being set. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  const Play._({
    required this.level,
    required this.hitsAt,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : hitsAt = const [],
        moves = 0,
        before = null;

  /// A play stood at a pattern, for the mark and the tests.
  Play.standing(this.level, List<int> hits)
      : hitsAt = List.unmodifiable(List.of(hits)..sort()),
        moves = 0,
        before = null;

  final Level level;

  /// The steps that are hits, sorted.
  final List<int> hitsAt;

  /// Taps taken, sets and lifts together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if the tresillo is
  /// never set.
  static const gaveUpAt = 20;

  List<int> get gaps => Rules.gaps(level.steps, hitsAt);

  bool get isEven => Rules.isEven(level.steps, hitsAt);

  bool get hasEqualGaps => hitsAt.length > 1 && Rules.equalGaps(level.steps, hitsAt);

  /// Taps a step: a hit is lifted, a rest becomes a hit.
  Play tap(int step) {
    if (isOver || step < 0 || step >= level.steps) return this;
    final next = hitsAt.contains(step) ? [for (final h in hitsAt) if (h != step) h] : ([...hitsAt, step]..sort());
    return Play._(level: level, hitsAt: next, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(hitsAt);

  /// A hopeless ask, admitted: the three hits are set as evenly as they
  /// go, the tresillo, and the gaps still differ; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (hitsAt.length == level.hits && isEven || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: lift a hit not in Euclid's rhythm, else set
  /// its next hit; null when nothing points anywhere.
  (Aim, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (final h in hitsAt) {
      if (!aim.contains(h)) return (Aim.lift, h);
    }
    for (final h in aim) {
      if (!hitsAt.contains(h)) return (Aim.set, h);
    }
    return null;
  }

  static String pointed((Aim, int) aim) => aim.$1 == Aim.lift ? 'Lift the hit at step ${aim.$2 + 1}.' : 'Set a hit at step ${aim.$2 + 1}.';
}

/// Why Euclid, and why the gaps: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Spread k hits round a ring of n steps as evenly as they will go. When '
      'n is a multiple of k the gaps come out equal, and when it is not the '
      'gaps come in two sizes a step apart, and so do the spans of two gaps, '
      'of three, and of every count round: that is what even means here, and '
      'the rhythms that manage it are exactly the ones Euclid\'s rule lays '
      'down, hit i at the floor of i n/k, and their turnings. The tresillo, '
      'the cinquillo, the bossa clave and the bembe bell are all of them '
      'Euclid\'s, which is Toussaint\'s finding of 2005.\n\n'
      'The game tries every pattern of the hits asked and marks the even ones, '
      'and lays Euclid\'s rhythm down and turns it round, and the two agree, '
      'pattern for pattern, on every ring to twelve steps with every count of '
      'hits, and on the rings here.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every pattern of the hits asked on '
      'the ring asked, tried in full.';
}
