/// One mere: its watches, their opening dialling, and the
/// asking.
class Mere {
  const Mere({
    required this.name,
    required this.lengths,
    required this.opens,
    required this.pairs,
    this.common,
    required this.ways,
    this.note,
  });

  final String name;

  /// The watches' lengths.
  final List<int> lengths;

  /// The starts the watches open on.
  final List<int> opens;

  /// Overlapping pairs asked, exactly.
  final int pairs;

  /// Shared hours asked: null for any count, nought for none.
  final int? common;

  /// Diallings of the sweep that land; nought on the hopeless
  /// mere, and the label says so.
  final int ways;

  /// One thing worth knowing about this mere, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final ring = pairs == lengths.length * (lengths.length - 1) ~/ 2
        ? 'every pair of watches overlaps'
        : 'exactly $pairs pairs overlap';
    if (common == null) return 'slide the watches till $ring';
    if (common == 0) {
      return 'slide the watches till $ring and no hour is shared';
    }
    return 'slide the watches till $ring with exactly $common '
        'shared hour${common == 1 ? '' : 's'}';
  }
}
