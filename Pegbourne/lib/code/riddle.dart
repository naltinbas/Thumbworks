/// One riddle, as it ships.
class Riddle {
  const Riddle({
    required this.name,
    required this.rows,
    required this.ways,
    this.note,
  });

  final String name;

  /// The old guesses and their marks: guess code, blacks, whites.
  final List<(int, int, int)> rows;

  /// How many codes agree with every row, as the sweep counted.
  final int ways;

  final String? note;

  bool get winnable => ways > 0;
}
