import 'rules.dart';

/// One triangle on the sham: how many rows, how many moves it is to be
/// turned in, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.rows,
    required this.moves,
    required this.ways,
    required this.placements,
    this.note,
  });

  final String name;

  /// Rows in the triangle.
  final int rows;

  /// Moves allowed.
  final int moves;

  /// Placements of the turned triangle within the moves, by the sweep;
  /// nought for the hopeless.
  final int ways;

  /// Placements of the turned triangle over the pennies at all.
  final int placements;

  /// One thing worth knowing about this triangle, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(rows);

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six', 10: 'ten', 15: 'fifteen', 21: 'twenty-one'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'turn the triangle of ${word(rules.coins)} pennies upside down in ${word(moves)} move${moves == 1 ? '' : 's'}';
}
