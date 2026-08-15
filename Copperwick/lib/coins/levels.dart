import 'level.dart';

/// The five triangles that ship.
///
/// Every number here is checked before the bake: every placement of the
/// turned triangle swept, the rows' bound and the third held to the
/// sweep on every triangle up to twelve rows, every sequence of moves
/// swept on the small ones, and tool/check_turnings.dart refuses the
/// lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three',
      rows: 2,
      moves: 1,
      ways: 3,
      placements: 6,
      note: 'One penny atop two: slide the top one down under the pair and '
          'the point is at the bottom. One move, and three placements of the '
          'six take in two of the three as they lie, one for each penny that '
          'could be the one to move.',
    ),
    Level(
      name: 'The Six',
      rows: 3,
      moves: 2,
      ways: 3,
      placements: 15,
      note: 'Two of the six move, the top penny and one bottom corner, and '
          'the turned triangle leans on the other corner: three placements of '
          'the fifteen take in four, one for each corner left where it lies. '
          'One move never does it: no placement takes in five.',
    ),
    Level(
      name: 'The Ten',
      rows: 4,
      moves: 3,
      ways: 1,
      placements: 28,
      note: 'The old one: the top penny down under the bottom row, the two '
          'bottom corners up beside the second row. Three moves, and one '
          'placement alone of the 28 takes in seven, the turned triangle whose '
          'middle is the upright\'s own.',
    ),
    Level(
      name: 'The Fifteen',
      rows: 5,
      moves: 5,
      ways: 3,
      placements: 45,
      note: 'Five of the fifteen move, the top three and the two bottom '
          'corners, and the turned triangle sits two rows lower; three '
          'placements of the 45 take in ten. A third of the pennies, rounded '
          'down, on every triangle up to twelve rows.',
    ),
    Level(
      name: 'The Ten in Two',
      rows: 4,
      moves: 2,
      ways: 0,
      placements: 28,
      note: 'Rows of four, three, two and one laid over rows of one, two, three '
          'and four: each turned row shares at most the shorter of the two, '
          'and the best of that is two, three and two, seven, when the four '
          'lies over the two. Every placement of the 28 was swept and none '
          'takes in eight, so three pennies must move and two moves never '
          'turn it.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
