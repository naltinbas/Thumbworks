import 'level.dart';
import 'levels.dart';

/// What the show-me points at.
enum Aim { pick, lay, lift }

/// A kite being slated. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  const Play._({
    required this.level,
    required this.laid,
    required this.picked,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : laid = const [],
        picked = null,
        moves = 0,
        before = null;

  /// A play stood at a slating, for the mark and the tests.
  Play.standing(this.level, List<(int, int)> slates)
      : laid = List.unmodifiable(slates),
        picked = null,
        moves = 0,
        before = null;

  final Level level;

  /// The slates laid, each (low cell, high cell).
  final List<(int, int)> laid;

  /// The cell picked towards a slate, or null.
  final int? picked;

  /// Layings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if the kite is
  /// never slated whole.
  static const gaveUpAt = 30;

  Set<int> get covered => {
        for (final (a, b) in laid) ...[a, b],
      };

  bool get isFull => laid.length * 2 == level.kite.count;

  int get acrossCount => level.kite.acrossCount(laid);

  int get downCount => laid.length - acrossCount;

  bool get isDone => level.winnable && level.meets(laid);

  /// Whether some bare cell has no bare neighbour, so the slating can
  /// go no further as it stands.
  bool get stuck {
    final c = covered;
    final k = level.kite;
    for (var i = 0; i < k.count; i++) {
      if (c.contains(i)) continue;
      final r = k.right(i), d = k.below(i);
      final l = k.index[(k.cells[i].$1 - 1, k.cells[i].$2)], u = k.index[(k.cells[i].$1, k.cells[i].$2 - 1)];
      if ([r, d, l, u].any((m) => m != null && !c.contains(m))) continue;
      return true;
    }
    return false;
  }

  /// A hopeless ask, admitted: the kite is slated whole and the count
  /// across is what it always is, or has tapped [gaveUpAt] times.
  bool get gaveUp => !level.winnable && (isFull || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The slate standing on [cell], or null.
  (int, int)? slateOn(int cell) {
    for (final s in laid) {
      if (s.$1 == cell || s.$2 == cell) return s;
    }
    return null;
  }

  /// Taps a cell: a covered cell lifts its slate; a bare cell is picked,
  /// or unpicked, or mated with the picked cell beside it.
  Play tap(int cell) {
    if (isOver || cell < 0 || cell >= level.kite.count) return this;
    final standing = slateOn(cell);
    if (standing != null) {
      return Play._(
        level: level,
        laid: [for (final s in laid) if (s != standing) s],
        picked: null,
        moves: moves + 1,
        before: this,
      );
    }
    final one = picked;
    if (one == null) return Play._(level: level, laid: laid, picked: cell, moves: moves, before: before);
    if (one == cell) return Play._(level: level, laid: laid, picked: null, moves: moves, before: before);
    if (!level.kite.beside(one, cell)) return Play._(level: level, laid: laid, picked: cell, moves: moves, before: before);
    final slate = one < cell ? (one, cell) : (cell, one);
    return Play._(
      level: level,
      laid: [...laid, slate],
      picked: null,
      moves: moves + 1,
      before: this,
    );
  }

  Play get back => before ?? this;

  /// What the pointer says: lift a slate not in the aim, else pick and
  /// lay the aim's next slate; null when nothing points anywhere.
  (Aim, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (final s in laid) {
      if (!aim.contains(s)) return (Aim.lift, s.$1);
    }
    for (final s in aim) {
      if (laid.contains(s)) continue;
      if (picked == s.$1) return (Aim.lay, s.$2);
      if (picked == s.$2) return (Aim.lay, s.$1);
      return (Aim.pick, s.$1);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((Aim, int) aim) => switch (aim.$1) {
        Aim.lift => 'Lift the ringed slate.',
        Aim.pick => 'Tap the ringed cell.',
        Aim.lay => 'Now tap the ringed cell beside it.',
      };
}

/// Why two to the triangle, and why never one across: the words behind
/// the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The kite of order n is the Aztec diamond, the cells within n of '
      'the middle by the taxi-cab measure: rows of 2, 4, ... 2n, 2n, ... 4, 2, '
      'and 2n(n+1) cells in all. Slate it with two-cell slates and the '
      'slatings come to exactly two to the n(n+1)/2: 2, 8, 64, 1,024, 32,768. '
      'Every row is even, so the slates hanging down out of a row are even in '
      'number, row by row from the top, and the slates lying across are what '
      'is left of an even count: even too. And the slatings sort by the count '
      'across along a row of Pascal\'s triangle, one, three, three, one for '
      'the order two.\n\n'
      'The game lays every slating out from the first bare cell on and counts '
      'them, orders one to five, and the counts are the formula\'s at every '
      'order; the counts across of every slating to order four are even and '
      'run along Pascal\'s rows.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every slating of the kite asked, '
      'laid out in full.';
}
