import 'tower.dart';

/// One peal: a tower, and what counts as ringing it.
class Peal {
  Peal({
    required this.name,
    required this.tower,
    required this.goalRows,
    required this.extents,
    this.hopeless = false,
  });

  final String name;
  final Tower tower;

  /// How many rows have to sound, rounds among them, before rounds strikes
  /// home again. The changes rung come to exactly this number.
  final int goalRows;

  /// How many ways there are of doing it, counted with direction. Written
  /// down here as well as worked out, so a test can hold the two against
  /// each other.
  final int extents;

  /// Whether the tower cannot ring its goal at all, and says so on the
  /// label.
  final bool hopeless;
}

/// The peals that ship.
///
/// The split tower is the labelled impossible one, in the house tradition:
/// its three changes never move a bell across the middle, so a bell that
/// starts in the front pair can never leave it, and four rows are all the
/// tower can reach of the twenty four. Its Why is an invariant anybody can
/// watch working.
class Peals {
  const Peals._();

  static final List<Peal> all = [
    Peal(
      name: 'Three Bells',
      tower: Towers.three('Three Bells'),
      goalRows: 6,
      extents: 2,
    ),
    Peal(
      name: 'The Plain Hunt',
      tower: Tower(
        name: 'The Plain Hunt',
        bells: 4,
        changes: const [
          Change('cross', [0, 2]),
          Change('mid', [1]),
        ],
      ),
      goalRows: 8,
      extents: 2,
    ),
    Peal(
      name: 'The Full Peal',
      tower: Towers.four('The Full Peal'),
      goalRows: 24,
      extents: 10792,
    ),
    Peal(
      name: 'Without the Cross',
      tower: Tower(
        name: 'Without the Cross',
        bells: 4,
        changes: const [
          Change('near', [0]),
          Change('mid', [1]),
          Change('far', [2]),
        ],
      ),
      goalRows: 24,
      extents: 88,
    ),
    Peal(
      name: 'The Split Tower',
      tower: Tower(
        name: 'The Split Tower',
        bells: 4,
        changes: const [
          Change('cross', [0, 2]),
          Change('near', [0]),
          Change('far', [2]),
        ],
      ),
      goalRows: 24,
      extents: 0,
      hopeless: true,
    ),
  ];

  static int get count => all.length;

  static Peal at(int number) => all[number.clamp(0, all.length - 1)];
}
