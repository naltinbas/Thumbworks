import 'moor.dart';
import 'rules.dart';

/// A moor being painted. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.moor, this.rules, this.painting, this.moves, this.before);

  factory Play.of(Moor moor) => Play._(
        moor,
        Rules(moor.stones, moor.paints),
        List.filled(moor.stones, 0),
        0,
        null,
      );

  /// A play stood at a painting, for the mark and the tests.
  factory Play.standing(Moor moor, List<int> painting) => Play._(
      moor, Rules(moor.stones, moor.paints), List.of(painting), 0, null);

  final Moor moor;
  final Rules rules;

  /// Each stone's paint, stone one at the front.
  final List<int> painting;

  /// Repaintings taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless moor admits it.
  static const gaveUpAt = 12;

  List<(int, int, int)> get badSums => Rules.badSums(painting);

  bool get isDone => moves > 0 && badSums.isEmpty;

  bool get gaveUp => !moor.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Repaints a stone with the next paint round.
  Play tapAt(int stone) {
    if (isOver || stone < 1 || stone > moor.stones) return this;
    final next = List.of(painting);
    next[stone - 1] = (next[stone - 1] + 1) % moor.paints;
    return Play._(moor, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The stone the sweep would repaint next towards a clean
  /// painting, with the paint it wants; null when none exists.
  (int, int)? get next {
    final aim = rules.painting();
    if (aim == null || isDone) return null;
    for (var stone = 1; stone <= moor.stones; stone++) {
      if (painting[stone - 1] != aim[stone - 1]) {
        return (stone, aim[stone - 1]);
      }
    }
    return null;
  }
}
