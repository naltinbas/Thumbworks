/// One charm to set, as it ships.
class Charm {
  const Charm({
    required this.name,
    required this.pins,
    required this.ways,
    this.note,
  });

  final String name;

  /// Coins held fast: cell to coin, row-major.
  final Map<int, int> pins;

  /// How many charms honour the pins, as the sweep counted.
  final int ways;

  final String? note;

  bool get winnable => ways > 0;

  bool isPinned(int cell) => pins.containsKey(cell);
}
