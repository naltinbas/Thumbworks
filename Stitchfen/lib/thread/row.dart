/// One row of the sampler: its stitches, what is already fixed,
/// and what the sweep counts for it.
class Row {
  const Row({
    required this.name,
    required this.stitches,
    this.fixed = const [],
    required this.ways,
    this.note,
  });

  final String name;

  /// Stitches along the row.
  final int stitches;

  /// Threads already stitched at the start of the row; these
  /// never flip.
  final List<String> fixed;

  /// Ladder-free threadings the sweep counts from what is fixed;
  /// nought on the hopeless row, and the label says so.
  final int ways;

  /// One thing worth knowing about this row, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => fixed.isEmpty
      ? 'thread $stitches stitches with no ladder'
      : 'finish the row of $stitches from its first '
          '${fixed.length}, with no ladder';
}
