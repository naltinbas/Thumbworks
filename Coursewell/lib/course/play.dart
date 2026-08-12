import 'rules.dart';
import 'yard.dart';

/// A yard being bricked. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.yard, this.rules, this.laid, this.picked, this.moves,
      this.before);

  factory Play.of(Yard yard) => Play._(yard,
      Rules(yard.width, yard.height), const [], null, 0, null);

  /// A play stood at a laying, for the mark and the tests.
  factory Play.standing(Yard yard, List<(int, int)> laid) =>
      Play._(yard, Rules(yard.width, yard.height), List.of(laid),
          null, laid.length, null);

  final Yard yard;
  final Rules rules;

  /// The bricks laid, each two cell indexes.
  final List<(int, int)> laid;

  /// The cell picked towards a brick, or null.
  final int? picked;

  /// Layings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless yard admits it.
  static const gaveUpAt = 18;

  Set<int> get covered => {
        for (final (a, b) in laid) ...[a, b],
      };

  bool get bricked => rules.bricked(laid);

  List<(bool, int)> get seams => seams_();
  List<(bool, int)> seams_() => rules.seams(laid);

  bool get isDone =>
      bricked &&
      (yard.asked == null || seams.length == yard.asked);

  bool get gaveUp => !yard.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether two cells sit side by side.
  bool beside(int a, int b) {
    final ax = a % yard.width, ay = a ~/ yard.width;
    final bx = b % yard.width, by = b ~/ yard.width;
    return (ax - bx).abs() + (ay - by).abs() == 1;
  }

  /// Picks a cell; the second lays a brick over the two, or
  /// lifts the brick standing there.
  Play tapAt(int cell) {
    if (isOver || cell < 0 || cell >= rules.cells) return this;
    final one = picked;
    if (one == null) {
      return Play._(yard, rules, laid, cell, moves, before);
    }
    if (one == cell) {
      return Play._(yard, rules, laid, null, moves, before);
    }
    final brick = one < cell ? (one, cell) : (cell, one);
    if (laid.contains(brick)) {
      return Play._(
          yard,
          rules,
          [for (final held in laid) if (held != brick) held],
          null,
          moves + 1,
          this);
    }
    if (!beside(one, cell) ||
        covered.contains(one) ||
        covered.contains(cell)) {
      return Play._(yard, rules, laid, null, moves, before);
    }
    return Play._(
        yard, rules, [...laid, brick], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The brick the sweep would lay or lift next towards a
  /// landing laying; null when none extends what stands.
  ((int, int), bool)? get next {
    if (isDone) return null;
    final aim = rules.laying(yard.asked);
    if (aim == null) return null;
    for (final brick in laid) {
      if (!aim.contains(brick)) return (brick, false);
    }
    for (final brick in aim) {
      if (!laid.contains(brick)) return (brick, true);
    }
    return null;
  }
}
