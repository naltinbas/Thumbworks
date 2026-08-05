import 'hills.dart';

/// One puzzle: a country, and the fewest beacons that light all of it.
class Watchland {
  const Watchland({
    required this.name,
    required this.hills,
    required this.sightlines,
    required this.fewest,
  });

  final String name;
  final List<Hill> hills;
  final List<(int, int)> sightlines;

  /// The fewest beacons that light every hill. Worked out rather than
  /// guessed: a test tries every set smaller than this one and finds nothing.
  final int fewest;

  Country get country => Country(hills: hills, sightlines: sightlines);

  int get count => hills.length;
}

/// The countries, in the order they are met.
///
/// Every one after the first is a country where lighting the hill that adds
/// the most dark hills, and then the next, and so on, uses more beacons than
/// it takes. That is what makes them puzzles rather than exercises, and a
/// test insists on it.
class Watchlands {
  const Watchlands._();

  static const all = <Watchland>[
    Watchland(
      name: 'The five',
      hills: [
        Hill('Cairn', 0.12, 0.68),
        Hill('Barrow', 0.32, 0.4),
        Hill('Tor', 0.5, 0.66),
        Hill('Knowe', 0.7, 0.38),
        Hill('Beacon', 0.88, 0.66),
      ],
      sightlines: [(0, 1), (1, 2), (2, 3), (3, 4)],
      fewest: 2,
    ),
    Watchland(
      name: 'Seven hills',
      hills: [
        Hill('Tor', 0.56, 0.58),
        Hill('Knowe', 0.76, 0.83),
        Hill('Cairn', 0.26, 0.87),
        Hill('Barrow', 0.28, 0.49),
        Hill('Fell', 0.27, 0.66),
        Hill('Beacon', 0.91, 0.79),
        Hill('Scar', 0.37, 0.23),
      ],
      sightlines: [(0, 1), (0, 3), (0, 4), (1, 5), (2, 4), (3, 4), (3, 6)],
      fewest: 3,
    ),
    Watchland(
      name: 'The eight',
      hills: [
        Hill('Beacon', 0.88, 0.1),
        Hill('Cairn', 0.23, 0.89),
        Hill('Knowe', 0.87, 0.81),
        Hill('Scar', 0.28, 0.11),
        Hill('Tor', 0.82, 0.32),
        Hill('Fell', 0.74, 0.51),
        Hill('Barrow', 0.56, 0.19),
        Hill('Rigg', 0.22, 0.72),
      ],
      sightlines: [(0, 4), (0, 6), (1, 7), (2, 5), (3, 6), (4, 5), (4, 6)],
      fewest: 3,
    ),
    Watchland(
      name: 'Nine',
      hills: [
        Hill('Tor', 0.74, 0.56),
        Hill('Fell', 0.57, 0.39),
        Hill('Beacon', 0.86, 0.12),
        Hill('Cairn', 0.27, 0.87),
        Hill('Knowe', 0.53, 0.8),
        Hill('Scar', 0.79, 0.31),
        Hill('Rigg', 0.82, 0.83),
        Hill('Barrow', 0.19, 0.3),
        Hill('Pike', 0.43, 0.51),
      ],
      sightlines: [
        (0, 1),
        (0, 4),
        (0, 5),
        (0, 6),
        (0, 8),
        (1, 5),
        (1, 8),
        (2, 5),
        (3, 4),
        (4, 6),
        (4, 8),
        (7, 8),
      ],
      fewest: 3,
    ),
    Watchland(
      name: 'The ridge',
      hills: [
        Hill('Rigg', 0.77, 0.9),
        Hill('Cairn', 0.16, 0.65),
        Hill('Fell', 0.41, 0.71),
        Hill('Pike', 0.5, 0.48),
        Hill('Scar', 0.51, 0.14),
        Hill('Barrow', 0.41, 0.28),
        Hill('Knowe', 0.48, 0.89),
        Hill('Tor', 0.74, 0.28),
        Hill('Howe', 0.21, 0.24),
        Hill('Beacon', 0.89, 0.39),
      ],
      sightlines: [
        (0, 6),
        (1, 2),
        (2, 3),
        (2, 6),
        (3, 4),
        (3, 5),
        (3, 7),
        (4, 5),
        (4, 7),
        (4, 8),
        (5, 7),
        (5, 8),
        (7, 9),
      ],
      fewest: 4,
    ),
    Watchland(
      name: 'The whole watch',
      hills: [
        Hill('Tor', 0.54, 0.63),
        Hill('Barrow', 0.29, 0.39),
        Hill('Beacon', 0.89, 0.31),
        Hill('Pike', 0.45, 0.4),
        Hill('Fell', 0.46, 0.79),
        Hill('Cairn', 0.16, 0.65),
        Hill('Howe', 0.12, 0.92),
        Hill('Scar', 0.43, 0.18),
        Hill('Knowe', 0.37, 0.62),
        Hill('Rigg', 0.85, 0.16),
        Hill('Ward', 0.62, 0.81),
      ],
      sightlines: [
        (0, 1),
        (0, 3),
        (0, 4),
        (0, 8),
        (0, 10),
        (1, 3),
        (1, 5),
        (1, 7),
        (1, 8),
        (2, 9),
        (3, 7),
        (3, 8),
        (4, 5),
        (4, 6),
        (4, 8),
        (4, 10),
        (5, 6),
        (5, 8),
        (8, 10),
      ],
      fewest: 3,
    ),
  ];

  static int get count => all.length;

  static Watchland at(int which) => all[which.clamp(0, all.length - 1)];
}
