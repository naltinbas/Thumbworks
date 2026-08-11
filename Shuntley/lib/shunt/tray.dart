/// One tray of tiles as it ships.
class Tray {
  const Tray({
    required this.name,
    required this.rows,
    required this.cols,
    required this.tiles,
    required this.fewest,
    this.note,
  });

  final String name;
  final int rows;
  final int cols;

  /// The cells as dealt, row by row, nought for the gap.
  final List<int> tiles;

  /// The fewest shunts home, or null for a tray that can never come
  /// home.
  final int? fewest;

  final String? note;

  bool get winnable => fewest != null;
}
