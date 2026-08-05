import 'moor.dart';

/// One puzzle: a round of places, and the shortest way to call at them all.
class Round {
  const Round({
    required this.name,
    required this.stops,
    required this.shortest,
  });

  final String name;
  final List<Stop> stops;

  /// The shortest round there is, in furlongs. Worked out rather than
  /// guessed: a test does the whole thing again from nothing.
  final int shortest;

  Moor get moor => Moor(stops);

  int get count => stops.length;
}

/// The rounds, in the order they are met.
class Rounds {
  const Rounds._();

  static const all = <Round>[
    Round(
      name: 'Five farms',
      stops: [
        Stop('the yard', 0.14, 0.5),
        Stop('Ashby', 0.36, 0.16),
        Stop('Redham', 0.72, 0.22),
        Stop('Stowe', 0.86, 0.62),
        Stop('Marle', 0.44, 0.84),
      ],
      shortest: 210,
    ),
    Round(
      name: 'The six',
      stops: [
        Stop('the yard', 0.1, 0.46),
        Stop('Ashby', 0.3, 0.12),
        Stop('Redham', 0.64, 0.1),
        Stop('Stowe', 0.9, 0.4),
        Stop('Marle', 0.66, 0.84),
        Stop('Wenn', 0.44, 0.5),
      ],
      shortest: 237,
    ),
    Round(
      name: 'The middle farm',
      stops: [
        Stop('the yard', 0.1, 0.5),
        Stop('Ashby', 0.34, 0.14),
        Stop('Redham', 0.72, 0.16),
        Stop('Stowe', 0.9, 0.54),
        Stop('Marle', 0.6, 0.88),
        Stop('Wenn', 0.24, 0.82),
        Stop('Holt', 0.5, 0.48),
      ],
      shortest: 274,
    ),
    Round(
      name: 'Both banks',
      stops: [
        Stop('the yard', 0.08, 0.32),
        Stop('Ashby', 0.28, 0.12),
        Stop('Redham', 0.52, 0.26),
        Stop('Stowe', 0.78, 0.12),
        Stop('Marle', 0.92, 0.4),
        Stop('Wenn', 0.52, 0.5),
        Stop('Holt', 0.42, 0.74),
        Stop('Barr', 0.14, 0.7),
      ],
      shortest: 250,
    ),
    Round(
      name: 'The long fen',
      stops: [
        Stop('the yard', 0.06, 0.44),
        Stop('Ashby', 0.3, 0.1),
        Stop('Redham', 0.46, 0.46),
        Stop('Stowe', 0.66, 0.12),
        Stop('Marle', 0.92, 0.3),
        Stop('Wenn', 0.86, 0.7),
        Stop('Holt', 0.6, 0.9),
        Stop('Barr', 0.28, 0.82),
        Stop('Cove', 0.72, 0.5),
      ],
      shortest: 308,
    ),
    Round(
      name: 'Ten gates',
      stops: [
        Stop('the yard', 0.08, 0.44),
        Stop('Ashby', 0.2, 0.14),
        Stop('Redham', 0.46, 0.08),
        Stop('Stowe', 0.72, 0.16),
        Stop('Marle', 0.92, 0.36),
        Stop('Wenn', 0.86, 0.7),
        Stop('Holt', 0.6, 0.9),
        Stop('Barr', 0.32, 0.84),
        Stop('Cove', 0.5, 0.52),
        Stop('Nye', 0.68, 0.46),
      ],
      shortest: 308,
    ),
    Round(
      name: 'The whole parish',
      stops: [
        Stop('the yard', 0.06, 0.5),
        Stop('Ashby', 0.18, 0.16),
        Stop('Redham', 0.44, 0.06),
        Stop('Stowe', 0.7, 0.14),
        Stop('Marle', 0.94, 0.34),
        Stop('Wenn', 0.88, 0.68),
        Stop('Holt', 0.64, 0.92),
        Stop('Barr', 0.34, 0.88),
        Stop('Cove', 0.14, 0.74),
        Stop('Nye', 0.42, 0.42),
        Stop('Ely', 0.66, 0.52),
      ],
      shortest: 331,
    ),
    Round(
      name: 'Twelve calls',
      stops: [
        Stop('the yard', 0.06, 0.46),
        Stop('Ashby', 0.16, 0.14),
        Stop('Redham', 0.4, 0.06),
        Stop('Stowe', 0.66, 0.1),
        Stop('Marle', 0.9, 0.26),
        Stop('Wenn', 0.94, 0.6),
        Stop('Holt', 0.74, 0.88),
        Stop('Barr', 0.44, 0.94),
        Stop('Cove', 0.16, 0.78),
        Stop('Nye', 0.36, 0.4),
        Stop('Ely', 0.6, 0.36),
        Stop('Tay', 0.62, 0.64),
      ],
      shortest: 363,
    ),
  ];

  static int get count => all.length;

  static Round at(int which) => all[which.clamp(0, all.length - 1)];
}
