import 'green.dart';
import 'rules.dart';

/// A green being roped. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.green, this.rules, this.laid, this.picked, this.moves,
      this.before);

  factory Play.of(Green green) => Play._(
      green, Rules(green.lanterns), const [], const [], 0, null);

  /// A play stood at a roping, for the mark and the tests.
  factory Play.standing(Green green, List<(int, int, int)> laid) =>
      Play._(green, Rules(green.lanterns), List.of(laid), const [],
          laid.length, null);

  final Green green;
  final Rules rules;

  /// Ropes the player has strung, the given ones not among them.
  final List<(int, int, int)> laid;

  /// Lanterns picked towards the next rope, nought to two of them.
  final List<int> picked;

  /// Ropes strung so far; a take-back rewinds the count with the
  /// rope.
  final int moves;

  final Play? before;

  /// The line past which the hopeless green admits it.
  static const gaveUpAt = 12;

  /// Every rope standing: the given ones and the laid ones.
  List<(int, int, int)> get ropes => [...green.given, ...laid];

  Map<(int, int), int> get ledger => rules.ledger(ropes);

  int get coveredOnce => rules.coveredOnce(ropes);

  List<(int, int)> get clashes => rules.clashes(ropes);

  bool get isDone => rules.closed(ropes);

  bool get gaveUp => !green.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a lantern towards a rope, or unpicks it; the third
  /// pick strings the rope.
  Play tapAt(int lantern) {
    if (isOver) return this;
    if (picked.contains(lantern)) {
      return Play._(green, rules, laid,
          [for (final p in picked) if (p != lantern) p], moves, before);
    }
    if (picked.length < 2) {
      return Play._(
          green, rules, laid, [...picked, lantern], moves, before);
    }
    final rope = _sorted(picked[0], picked[1], lantern);
    if (ropes.contains(rope)) {
      return Play._(green, rules, laid, const [], moves, before);
    }
    return Play._(
        green, rules, [...laid, rope], const [], moves + 1, this);
  }

  static (int, int, int) _sorted(int a, int b, int c) {
    final three = [a, b, c]..sort();
    return (three[0], three[1], three[2]);
  }

  /// Takes back the last strung rope.
  Play get back => before ?? this;

  /// Lets go of the picked lanterns without unstringing anything.
  Play get unpicked =>
      Play._(green, rules, laid, const [], moves, before);

  /// The rope the search would string next, from its first
  /// closing; null when no closing is in reach.
  (int, int, int)? get next {
    final whole = rules.closing(ropes);
    if (whole == null) {
      // A clash or a dead end stands: point at nothing until the
      // player takes something back.
      return null;
    }
    for (final rope in whole) {
      if (!ropes.contains(rope)) return rope;
    }
    return null;
  }
}
