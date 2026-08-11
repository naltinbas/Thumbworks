/// One shelf of paired blocks, and whether it can be set at all.
///
/// There are two blocks of each number, one to [pairs], and a row of seats
/// twice as long. The rule is the number itself: the two blocks of k must
/// hold exactly k seats between them. Some shelves can be set and some
/// cannot, and which is which is arithmetic.
class Level {
  const Level({
    required this.name,
    required this.pairs,
    required this.possible,
    required this.ways,
    this.note,
  });

  final String name;

  /// How many pairs: numbers one to this.
  final int pairs;

  /// Whether any setting exists. Written down here as well as worked out,
  /// so a test can hold the two against each other.
  final bool possible;

  /// How many settings there are, counting mirror images apart, or nought.
  /// Written down and checked the same way.
  final int ways;

  /// A sentence of its own this shelf has earned, said after the why, or
  /// null for the shelves whose story is the usual one.
  final String? note;

  int get seats => pairs * 2;
}
