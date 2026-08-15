import 'rope.dart';
import 'rules.dart';

/// A rope being marked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.rope, this.rules, this.marks, this.moves, this.before);

  factory Play.of(Rope rope) => Play._(rope, Rules(rope.knots), const [], 0, null);

  /// A play stood at a marking, for the mark and the tests.
  factory Play.standing(Rope rope, List<int> marks) =>
      Play._(rope, Rules(rope.knots), List.of(marks), marks.length, null);

  final Rope rope;
  final Rules rules;

  /// The knots the two pegs stand on, in the order set; the third peg
  /// stands at knot nought.
  final List<int> marks;

  /// Pegs set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless rope admits it.
  static const gaveUpAt = 12;

  bool get full => marks.length == 2;

  /// The sides round the pegs, when both stand.
  Sides? get sides {
    if (!full) return null;
    final i = marks[0] < marks[1] ? marks[0] : marks[1];
    final j = marks[0] < marks[1] ? marks[1] : marks[0];
    return rules.sidesOf(i, j);
  }

  bool get closes => sides != null && Rules.closes(sides!);

  int? get shortfall => sides == null ? null : Rules.shortfall(sides!);

  bool get isDone => sides != null && Rules.square(sides!);

  bool get gaveUp => !rope.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(int knot) =>
      !isOver && knot > 0 && knot < rope.knots && (marks.contains(knot) || !full);

  /// Taps a knot: stands a peg on it, or lifts the one there.
  Play tap(int knot) {
    if (!touches(knot)) return this;
    final held = marks.contains(knot) ? [for (final m in marks) if (m != knot) m] : [...marks, knot];
    return Play._(rope, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', knot) for a peg off the aim,
  /// or ('set', knot) for the next; null when nothing lands.
  (String, int)? get next {
    if (isOver || !rope.winnable) return null;
    final aim = aimFor(rope);
    if (aim == null) return null;
    final want = [aim.$1, aim.$2];
    for (final m in marks) {
      if (!want.contains(m)) return ('lift', m);
    }
    for (final k in want) {
      if (!marks.contains(k)) return ('set', k);
    }
    return null;
  }

  /// The sweep's first square marking, kept once found.
  static (int, int)? aimFor(Rope rope) {
    if (!_aims.containsKey(rope.knots)) {
      _aims[rope.knots] = Rules(rope.knots).landing();
    }
    return _aims[rope.knots];
  }

  static final _aims = <int, (int, int)?>{};
}
