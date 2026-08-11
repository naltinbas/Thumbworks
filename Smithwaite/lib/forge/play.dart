import 'fewest.dart';
import 'puzzle.dart';

/// A puzzle part worked: how the rings lie, and the moves spent.
class Play {
  const Play._(this.puzzle, this.state, this.made, this.before);

  Play.of(Puzzle puzzle) : this._(puzzle, puzzle.start, 0, null);

  final Puzzle puzzle;

  /// The rings as bits, lowest bit the first ring on the bar.
  final int state;

  /// Moves made.
  final int made;

  /// The puzzle as it lay before the last move, or null at the start.
  final Play? before;

  bool get isFree => state == 0;

  bool get isFewest => made == puzzle.fewest;

  bool isOn(int ring) => (state >> ring) & 1 == 1;

  /// Whether that ring can come on or off where things stand.
  bool mayMove(int ring) =>
      !isFree && Moves.mayMove(puzzle.rings, state, ring);

  /// The move. Returns this unchanged when the cords do not allow it.
  Play move(int ring) {
    if (!mayMove(ring)) return this;
    return Play._(puzzle, state ^ (1 << ring), made + 1, this);
  }

  /// The last move back, or this at the start.
  Play get back => before ?? this;

  /// The fewest moves the bar can still be freed in.
  int get couldStillBe => made + Moves.walk(puzzle.rings)[state];

  /// What the smith's count reads off the rings as they lie.
  int get smithSays => Moves.bySmith(puzzle.rings, state);

  /// The ring to move next: the one of the at-most-two that goes forward.
  /// Null when the bar is free.
  int? get next {
    if (isFree) return null;
    final away = Moves.walk(puzzle.rings)[state];
    for (var ring = 0; ring < puzzle.rings; ring++) {
      if (!mayMove(ring)) continue;
      if (Moves.walk(puzzle.rings)[state ^ (1 << ring)] == away - 1) {
        return ring;
      }
    }
    return null;
  }
}
