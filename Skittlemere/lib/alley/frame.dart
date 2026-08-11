/// One alley as it ships.
class Frame {
  const Frame({
    required this.name,
    required this.rows,
    required this.count,
    this.note,
  });

  final String name;

  /// The rows of skittles as they stand at the start.
  final List<int> rows;

  /// The alley's count at the start, by the skittle arithmetic. The
  /// mover has the alley exactly when it is not nought.
  final int count;

  final String? note;

  bool get winnable => count != 0;

  int get skittles => rows.fold(0, (held, row) => held + row);
}
