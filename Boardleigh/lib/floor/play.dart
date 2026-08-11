import 'room.dart';
import 'rules.dart';

/// A floor being laid. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.room, this.rules, this.planks, this.moves, this.before);

  Play.of(Room room)
      : this._(room, Rules(room.wide, room.high, room.cells), const [],
            0, null);

  final Room room;
  final Rules rules;

  /// The planks laid, each as its two cells.
  final List<(int, int)> planks;

  final int moves;

  final Play? before;

  int get covered {
    var mask = 0;
    for (final (one, other) in planks) {
      mask |= (1 << one) | (1 << other);
    }
    return mask;
  }

  int get uncovered => room.cells & ~covered;

  bool get isDone => uncovered == 0;

  bool isCovered(int cell) => covered & (1 << cell) != 0;

  /// Whether two cells may take a plank: both in the room, empty, and
  /// beside each other.
  bool mayLay(int one, int other) {
    if (!rules.inRoom(one) || !rules.inRoom(other)) return false;
    if (isCovered(one) || isCovered(other)) return false;
    final oneRow = one ~/ room.wide;
    final otherRow = other ~/ room.wide;
    return (oneRow == otherRow && (one - other).abs() == 1) ||
        (one % room.wide == other % room.wide &&
            (oneRow - otherRow).abs() == 1);
  }

  Play lay(int one, int other) {
    if (isDone || !mayLay(one, other)) return this;
    final low = one < other ? one : other;
    final high = one < other ? other : one;
    return Play._(
        room, rules, [...planks, (low, high)], moves + 1, this);
  }

  /// Lifts the plank covering a cell, if any.
  Play lift(int cell) {
    for (final plank in planks) {
      if (plank.$1 == cell || plank.$2 == cell) {
        return Play._(
          room,
          rules,
          [for (final held in planks) if (held != plank) held],
          moves + 1,
          this,
        );
      }
    }
    return this;
  }

  Play get back => before ?? this;

  /// Whether what is left can still be planked.
  bool get canStill => rules.canStill(uncovered);

  /// A plank from a full laying of what is left, or null.
  (int, int)? get next => rules.next(uncovered);
}
