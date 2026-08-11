/// One room to floor, as it ships.
class Room {
  const Room({
    required this.name,
    required this.wide,
    required this.high,
    required this.cells,
    required this.ways,
    this.note,
  });

  final String name;
  final int wide;
  final int high;

  /// The room's cells, as a bitmask over the grid.
  final int cells;

  /// How many full layings there are, as the count found.
  final int ways;

  final String? note;

  bool get winnable => ways > 0;
}
