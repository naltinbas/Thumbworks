/// One evening in the garden: how it was planted, and what the draught did.
class Evening {
  const Evening({
    required this.name,
    required this.planted,
    required this.snuffed,
    this.note,
  });

  final String name;

  /// The gardener's planting, every hedge even, lamps as bits.
  final int planted;

  /// The lamps the draught changed this evening: none, one, or two.
  final List<int> snuffed;

  /// A sentence of its own this evening has earned, said after the why,
  /// or null for the evenings whose story is the usual one.
  final String? note;

  /// The garden as found: the planting with the draught's work done.
  int get seen {
    var pattern = planted;
    for (final lamp in snuffed) {
      pattern ^= 1 << (lamp - 1);
    }
    return pattern;
  }
}
