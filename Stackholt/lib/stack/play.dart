import 'boxset.dart';
import 'rules.dart';

/// A stack being turned. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.set, this.stood, this.moves, this.before);

  factory Play.of(BoxSet set) =>
      Play._(set, List.of(set.opens), 0, null);

  /// A play stood at given turnings, for the mark and the tests.
  factory Play.standing(BoxSet set, List<(int, int, int, int)> stood) =>
      Play._(set, List.of(stood), 0, null);

  final BoxSet set;

  /// Each box's turning: sleeve held vertical, the two flips, and
  /// the spin.
  final List<(int, int, int, int)> stood;

  /// Spins and tips taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless stack admits it.
  static const gaveUpAt = 16;

  /// The walls each box shows, front, right, back, left.
  List<(String, String, String, String)> get walls => [
        for (var box = 0; box < set.count; box++)
          wallsOf(set.boxes[box], stood[box]),
      ];

  /// The walls a box shows in one turning, front, right, back,
  /// left; shared with the mark's search.
  static (String, String, String, String) wallsOf(
      List<(String, String)> sleeves, (int, int, int, int) turn) {
    final (axis, flipP, flipQ, spin) = turn;
    final axes = [
      (sleeves[1], sleeves[2]),
      (sleeves[0], sleeves[2]),
      (sleeves[0], sleeves[1]),
    ];
    var (p, q) = axes[axis];
    if (flipP == 1) p = (p.$2, p.$1);
    if (flipQ == 1) q = (q.$2, q.$1);
    final ring = [p.$1, q.$1, p.$2, q.$2];
    return (
      ring[spin % 4],
      ring[(spin + 1) % 4],
      ring[(spin + 2) % 4],
      ring[(spin + 3) % 4],
    );
  }

  /// The walls that clash: for each wall, the boxes wearing a
  /// colour some earlier box already wears there.
  Set<(int, int)> get clashes {
    final bad = <(int, int)>{};
    for (var wall = 0; wall < 4; wall++) {
      final seen = <String, int>{};
      for (var box = 0; box < set.count; box++) {
        final face = [
          walls[box].$1,
          walls[box].$2,
          walls[box].$3,
          walls[box].$4,
        ][wall];
        if (seen.containsKey(face)) {
          bad.add((wall, box));
          bad.add((wall, seen[face]!));
        } else {
          seen[face] = box;
        }
      }
    }
    return bad;
  }

  bool get isDone => Rules.settled(walls);

  bool get gaveUp => !set.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  Play _turned(int box, (int, int, int, int) turn) {
    final next = List.of(stood);
    next[box] = turn;
    return Play._(set, next, moves + 1, this);
  }

  /// Spins [box] a quarter turn.
  Play spinAt(int box) {
    if (isOver) return this;
    final (axis, flipP, flipQ, spin) = stood[box];
    return _turned(box, (axis, flipP, flipQ, (spin + 1) % 4));
  }

  /// Tips [box] onto its next sleeve; each third tip round walks
  /// the flips too, so every turning is reachable.
  Play tipAt(int box) {
    if (isOver) return this;
    var (axis, flipP, flipQ, spin) = stood[box];
    axis = (axis + 1) % 3;
    if (axis == 0) {
      flipP = 1 - flipP;
      if (flipP == 0) flipQ = 1 - flipQ;
    }
    return _turned(box, (axis, flipP, flipQ, spin));
  }

  Play get back => before ?? this;

  /// The box the search would turn next, with the walls it wants:
  /// the first box standing off a found settling. Null when no
  /// settling is in reach.
  (int, (String, String, String, String))? get next {
    final aim = Rules.settling(set.boxes);
    if (aim == null || isDone) return null;
    for (var box = 0; box < set.count; box++) {
      if (walls[box] != aim[box]) return (box, aim[box]);
    }
    return null;
  }
}
