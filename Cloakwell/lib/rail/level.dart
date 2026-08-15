/// One rail on the sham: the coats as they hang, the swaps allowed, and
/// what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.row,
    required this.swaps,
    required this.ways,
    required this.sequences,
    this.note,
  });

  final String name;

  /// The coats on the hooks, left to right.
  final List<int> row;

  /// Swaps of neighbours to make, exactly.
  final int swaps;

  /// Sequences of that many swaps that sort the row, by the sweep.
  final int ways;

  /// Sequences of that many swaps, all told: (hooks - 1) to the power.
  final int sequences;

  /// One thing worth knowing about this rail, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 4: 'four', 5: 'five', 6: 'six', 10: 'ten'};

  /// The task, told in words for the ledger.
  String get task => 'sort the coats ${row.join(', ')} in ${_words[swaps] ?? '$swaps'} swaps of neighbours';
}
