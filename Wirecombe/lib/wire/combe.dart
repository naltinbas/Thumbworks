/// One combe: its cottages and the lane's ends asked of its run.
class Combe {
  const Combe({
    required this.name,
    required this.cottages,
    required this.ends,
    required this.ways,
    this.note,
  });

  final String name;

  /// Cottages standing in the combe.
  final int cottages;

  /// Lane's ends the run must keep, or null for any run at all.
  final int? ends;

  /// Runs of the sweep that do it; nought on the hopeless combe,
  /// and the label says so.
  final int ways;

  /// One thing worth knowing about this combe, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final lines = cottages - 1;
    return ends == null
        ? 'wire $cottages cottages into one run of $lines lines'
        : 'wire $cottages cottages into one run keeping '
            '$ends lane\'s end${ends == 1 ? '' : 's'}';
  }
}
