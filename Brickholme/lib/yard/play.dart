import 'level.dart';
import 'rules.dart';

/// A yard being paved. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.bricks, this.across, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, const [], true, 0, null);

  /// A play stood at a paving, for the mark and the tests.
  factory Play.standing(Level level, List<Brick> bricks) => Play._(level, level.rules, List.of(bricks), true, bricks.length, null);

  final Level level;
  final Rules rules;

  /// The bricks laid, in the order laid.
  final List<Brick> bricks;

  /// Whether the next brick goes across, or down.
  final bool across;

  /// Bricks laid, counted; lifting and turning are free.
  final int moves;

  final Play? before;

  /// The line past which the hopeless yard admits it, if it is not
  /// stuck first.
  static const gaveUpAt = 30;

  Set<int> get covered => rules.covered(bricks);

  /// Flags bare, the drain not counted.
  int get bare => rules.flags - 1 - covered.length;

  List<Brick> get openings => rules.openings(bricks);

  bool get isDone => rules.paved(bricks);

  bool get stuck => !isDone && openings.isEmpty;

  bool get gaveUp => !level.winnable && !isDone && (stuck || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The brick lying on flag [c], if any.
  Brick? brickOn(int c) {
    for (final b in bricks) {
      if (rules.flagsOf(b)?.contains(c) ?? false) return b;
    }
    return null;
  }

  /// Turns the next brick the other way.
  Play get turn => isOver ? this : Play._(level, rules, bricks, !across, moves, this);

  /// Sets which way the next brick goes.
  Play facing(bool across) => isOver || across == this.across ? this : Play._(level, rules, bricks, across, moves, this);

  /// Taps flag [c]: lifts the brick lying there, or lays one from there
  /// the way the yard is facing, if it fits.
  Play tap(int c) {
    if (isOver || c < 0 || c >= rules.flags) return this;
    final lying = brickOn(c);
    if (lying != null) {
      return Play._(level, rules, [for (final b in bricks) if (b != lying) b], across, moves, this);
    }
    final brick = (c, across);
    if (!rules.fits(brick, bricks)) return this;
    return Play._(level, rules, [...bricks, brick], across, moves + 1, this);
  }

  /// Undoes the last laying, or the last lift or turn.
  Play get back => before ?? this;

  /// What the show-me points at: ('lift', brick) for a laid brick off the
  /// walk's paving, else ('lay', brick) for the first brick of it not
  /// laid; null when nothing lands.
  (String, Brick)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (final b in bricks) {
      if (!aim.contains(b)) return ('lift', b);
    }
    for (final b in aim) {
      if (!bricks.contains(b)) return ('lay', b);
    }
    return null;
  }

  /// The walk's paving, kept once found.
  static List<Brick>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = level.rules.paving();
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<Brick>?>{};
}
