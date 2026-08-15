/// One asking on the sham: how many even rows, and what the sweep
/// found.
class Asking {
  const Asking({
    required this.name,
    required this.rows,
    required this.heaps,
    this.note,
  });

  final String name;

  /// Even rows asked, exactly.
  final int rows;

  /// Heaps on the board that have them, by the sweep; empty for the
  /// hopeless.
  final List<int> heaps;

  /// One thing worth knowing about this asking, said by the why.
  final String? note;

  int get ways => heaps.length;

  bool get winnable => heaps.isNotEmpty;

  /// The task, told in words for the ledger.
  String get task => 'pick a heap of the hundred with exactly $rows even rows';
}
