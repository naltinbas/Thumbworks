/// One ruler to cut, as it ships.
class Cut {
  const Cut({
    required this.name,
    required this.length,
    required this.notches,
    required this.perfect,
    required this.ways,
    this.note,
  });

  final String name;

  /// The ruler's whole length.
  final int length;

  /// How many notches to cut.
  final int notches;

  /// Whether the ask is a perfect ruler: every length measured, not
  /// merely none twice.
  final bool perfect;

  /// How many cuttings meet the ask, as the sweep counted.
  final int ways;

  final String? note;

  bool get winnable => ways > 0;
}
