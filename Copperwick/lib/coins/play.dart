import 'level.dart';
import 'rules.dart';

/// A triangle being turned. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.lying, this.held, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, level.rules.upright.toSet(), null, 0, null);

  /// A play stood at a laying, for the mark and the tests.
  factory Play.standing(Level level, Iterable<Spot> lying, {int moves = 0}) =>
      Play._(level, level.rules, Set.of(lying), null, moves, null);

  final Level level;
  final Rules rules;

  /// Where the pennies lie.
  final Set<Spot> lying;

  /// The penny taken up, if any.
  final Spot? held;

  /// Pennies slid, counted; taking one up is free.
  final int moves;

  final Play? before;

  bool get turned => rules.isTurned(lying);

  bool get isDone => turned;

  bool get spent => moves >= level.moves;

  bool get gaveUp => !level.winnable && spent && !turned;

  /// The moves spent on a triangle that could have turned.
  bool get missed => level.winnable && spent && !turned;

  bool get isOver => turned || spent;

  bool onTable(Spot spot) => rules.table.contains(spot);

  bool touches(Spot spot) => !isOver && onTable(spot);

  /// The most pennies any turned triangle takes in as they lie now.
  int get bestFit {
    var best = 0;
    for (var b = -rules.rows; b <= 3 * rules.rows; b++) {
      for (var a = -2 * rules.rows; a <= 3 * rules.rows; a++) {
        final s = rules.shared(lying, (a, b));
        if (s > best) best = s;
      }
    }
    return best;
  }

  /// Taps a spot: a penny is taken up or put down again, and an empty
  /// spot takes the penny in hand.
  Play tap(Spot spot) {
    if (!touches(spot)) return this;
    if (lying.contains(spot)) {
      return Play._(level, rules, lying, held == spot ? null : spot, moves, this);
    }
    final from = held;
    if (from == null) return this;
    final next = Set<Spot>.of(lying)
      ..remove(from)
      ..add(spot);
    return Play._(level, rules, next, null, moves + 1, this);
  }

  /// Undoes the last slide, or puts a penny in hand down.
  Play get back {
    final was = before;
    if (was == null) return held == null ? this : Play._(level, rules, lying, null, moves, null);
    if (was.moves < moves) return Play._(level, rules, was.lying, null, was.moves, was.before);
    return was.back;
  }

  /// What the show-me points at: ('take', penny) for a penny off the
  /// aimed triangle when none is in hand, ('to', spot) for its place
  /// once one is; null when nothing lands.
  (String, Spot)? get next {
    if (isOver || !level.winnable) return null;
    final target = aimFor(level);
    final hand = held;
    if (hand != null && !target.contains(hand)) {
      for (final spot in target) {
        if (!lying.contains(spot)) return ('to', spot);
      }
      return null;
    }
    for (final spot in rules.upright) {
      if (lying.contains(spot) && !target.contains(spot)) return ('take', spot);
    }
    for (final spot in lying) {
      if (!target.contains(spot)) return ('take', spot);
    }
    return null;
  }

  /// The turned triangle the pointer aims at, kept once found.
  static Set<Spot> aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final rules = level.rules;
      _aims[level.name] = rules.turned(rules.aim).toSet();
    }
    return _aims[level.name]!;
  }

  static final _aims = <String, Set<Spot>>{};
}
