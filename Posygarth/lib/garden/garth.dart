/// One garth: so many beds a side, and whether it can bloom at all.
class Garth {
  const Garth({
    required this.name,
    required this.size,
    required this.possible,
    this.seeded = const [],
    this.note,
  });

  final String name;

  /// Beds a side; flowers and colours to match.
  final int size;

  /// Whether any planting exists. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final bool possible;

  /// Beds planted before you arrive, as (bed, flower, colour).
  final List<(int, int, int)> seeded;

  /// A sentence of its own this garth has earned, said after the why, or
  /// null for the garths whose story is the usual one.
  final String? note;

  int get beds => size * size;
}
