/// One consignment: four crates, each three opposite-face pairs.
class Consignment {
  const Consignment({
    required this.name,
    required this.crates,
    required this.ways,
    this.note,
  });

  final String name;

  /// crates[crate] holds three (paint, paint) opposite pairs.
  final List<List<(int, int)>> crates;

  /// How many assignments stack fair, counted whole. Written down here
  /// as well as worked out, so a test can hold the two against each
  /// other.
  final int ways;

  bool get possible => ways > 0;

  /// A sentence of its own this consignment has earned, said after the
  /// why, or null for the ones whose story is the usual one.
  final String? note;
}
