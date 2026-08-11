/// A batch of cakes on the griddle, and what sorting it costs.
///
/// The cakes are numbered by size, 1 the smallest, and listed from the
/// griddle up. The only move there is: slide the slice under a cake and
/// turn everything above it over in one go. The batch is served when the
/// sizes run smallest on top to biggest on the griddle.
class Batch {
  const Batch({required this.name, required this.cakes, required this.fewest});

  final String name;

  /// Sizes from the griddle up.
  final List<int> cakes;

  /// The fewest flips that serve it, found by the full walk before it was
  /// written down, so a test can hold the two against each other.
  final int fewest;

  int get many => cakes.length;
}
