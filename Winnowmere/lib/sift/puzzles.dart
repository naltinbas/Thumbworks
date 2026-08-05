import 'network.dart';

/// One puzzle: how many lines, what is already there, and the fewest
/// comparators that will sort them.
class Sifting {
  const Sifting({
    required this.name,
    required this.lines,
    required this.fewest,
    this.given = const [],
  });

  final String name;
  final int lines;

  /// The fewest comparators that sort this many lines. Worked out rather than
  /// looked up: `make fewest` walks every network there is, and a test does
  /// the same for everything up to six lines.
  final int fewest;

  /// Comparators already in place, as pairs of lines. They are the first few
  /// of a network that really does sort in [fewest], so finishing one of
  /// these in par is always possible.
  final List<(int, int)> given;

  Sieve get start =>
      Sieve(lines, [for (final (one, other) in given) Cross(one, other)]);

  int get toFind => fewest - given.length;
}

/// The puzzles, in the order they are met.
///
/// Every number here is the fewest there is, and every one that starts with
/// comparators already in place starts with the first few of a network that
/// finishes in that number.
class Siftings {
  const Siftings._();

  static const all = <Sifting>[
    Sifting(name: 'Two lines', lines: 2, fewest: 1),
    Sifting(name: 'Three lines', lines: 3, fewest: 3),
    Sifting(name: 'Four lines', lines: 4, fewest: 5),
    Sifting(
      name: 'Five, begun',
      lines: 5,
      fewest: 9,
      given: [(0, 1), (0, 2), (0, 3), (0, 4)],
    ),
    Sifting(name: 'Five lines', lines: 5, fewest: 9),
    Sifting(
      name: 'Six, begun',
      lines: 6,
      fewest: 12,
      given: [(0, 1), (0, 2), (1, 2), (3, 4), (3, 5), (0, 3)],
    ),
    Sifting(name: 'Six lines', lines: 6, fewest: 12),
    Sifting(
      name: 'Seven, begun',
      lines: 7,
      fewest: 16,
      given: [(0, 1), (0, 2), (1, 2), (3, 4), (0, 3), (5, 6), (0, 5), (3, 5)],
    ),
  ];

  static int get count => all.length;

  static Sifting at(int which) => all[which.clamp(0, all.length - 1)];
}
