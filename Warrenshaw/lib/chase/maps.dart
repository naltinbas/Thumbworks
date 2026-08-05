import 'chart.dart';

/// One map, with where the two of them start.
class Warren {
  const Warren({
    required this.name,
    required this.places,
    required this.paths,
    required this.seeker,
    required this.runner,
    this.par,
    this.hopeless = false,
  });

  final String name;
  final List<Place> places;
  final List<(int, int)> paths;

  /// Where the seeker starts, and where the runner does.
  final int seeker;
  final int runner;

  /// The fewest moves the chase can be won in, against a runner who plays as
  /// well as it can. Null on the map where there is no winning it at all.
  final int? par;

  /// Whether the runner gets away for ever whatever anybody does. One map
  /// here is like that, on purpose.
  final bool hopeless;

  Chart get chart => Chart(places: places, paths: paths);
}

/// The maps, in the order they are met.
///
/// Every one of them but the last can be won, and the number on it is the
/// fewest moves it takes against a runner playing as well as it can — worked
/// out by settling every position of the chase rather than by playing it.
///
/// The last one cannot be won by anybody, and that is what it is for.
class Warrens {
  const Warrens._();

  static const all = <Warren>[
    Warren(
      name: 'The fork',
      places: [
        Place('gate', 0.5, 0.86),
        Place('crossing', 0.5, 0.62),
        Place('elm', 0.28, 0.38),
        Place('barn', 0.72, 0.38),
        Place('beck', 0.16, 0.14),
        Place('fold', 0.84, 0.14),
      ],
      paths: [(0, 1), (1, 2), (1, 3), (2, 4), (3, 5)],
      seeker: 0,
      runner: 4,
      par: 3,
    ),
    Warren(
      name: 'The mill',
      places: [
        Place('mill', 0.5, 0.32),
        Place('weir', 0.3, 0.5),
        Place('race', 0.7, 0.5),
        Place('ford', 0.5, 0.68),
        Place('lane', 0.12, 0.32),
        Place('barn', 0.88, 0.32),
        Place('beck', 0.5, 0.9),
      ],
      paths: [
        (0, 1),
        (0, 2),
        (1, 2),
        (1, 3),
        (2, 3),
        (1, 4),
        (2, 5),
        (3, 6),
      ],
      seeker: 4,
      runner: 6,
      par: 3,
    ),
    Warren(
      name: 'The lane',
      places: [
        Place('gate', 0.08, 0.44),
        Place('elm', 0.29, 0.56),
        Place('well', 0.5, 0.44),
        Place('barn', 0.71, 0.56),
        Place('beck', 0.92, 0.44),
      ],
      paths: [(0, 1), (1, 2), (2, 3), (3, 4)],
      seeker: 0,
      runner: 4,
      par: 4,
    ),
    Warren(
      name: 'The green',
      places: [
        Place('green', 0.5, 0.5),
        Place('oak', 0.5, 0.24),
        Place('pound', 0.28, 0.72),
        Place('forge', 0.72, 0.72),
        Place('gate', 0.5, 0.06),
        Place('beck', 0.1, 0.9),
        Place('fold', 0.9, 0.9),
      ],
      paths: [
        (0, 1),
        (0, 2),
        (0, 3),
        (1, 2),
        (2, 3),
        (1, 4),
        (2, 5),
        (3, 6),
      ],
      seeker: 4,
      runner: 6,
      par: 4,
    ),
    Warren(
      name: 'The spinney',
      places: [
        Place('gate', 0.06, 0.60),
        Place('elm', 0.20, 0.46),
        Place('crossing', 0.36, 0.56),
        Place('well', 0.56, 0.44),
        Place('barn', 0.74, 0.56),
        Place('beck', 0.94, 0.44),
        Place('spinney', 0.30, 0.26),
        Place('rookery', 0.18, 0.07),
        Place('pound', 0.62, 0.72),
        Place('fold', 0.74, 0.92),
      ],
      paths: [
        (0, 1),
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 5),
        (2, 6),
        (6, 7),
        (3, 8),
        (8, 9),
      ],
      seeker: 0,
      runner: 5,
      par: 5,
    ),
    Warren(
      name: 'The warren',
      places: [
        Place('gate', 0.06, 0.86),
        Place('elm', 0.2, 0.76),
        Place('well', 0.34, 0.84),
        Place('crossing', 0.48, 0.68),
        Place('barn', 0.56, 0.5),
        Place('mound', 0.66, 0.3),
        Place('burrow', 0.9, 0.28),
        Place('fold', 0.82, 0.52),
      ],
      paths: [
        (0, 1),
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 5),
        (5, 6),
        (6, 7),
        (5, 7),
      ],
      seeker: 0,
      runner: 7,
      par: 6,
    ),
    Warren(
      name: 'The ring',
      places: [
        Place('north gate', 0.5, 0.12),
        Place('east gate', 0.88, 0.5),
        Place('south gate', 0.5, 0.88),
        Place('west gate', 0.12, 0.5),
      ],
      paths: [(0, 1), (1, 2), (2, 3), (3, 0)],
      seeker: 0,
      runner: 2,
      hopeless: true,
    ),
  ];

  static int get count => all.length;

  static Warren at(int which) => all[which.clamp(0, all.length - 1)];
}
