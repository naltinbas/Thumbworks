/// One harvest on the sham: how many sheaves, what the stooks must
/// be, and what the walk of every partition found.
class Level {
  const Level({
    required this.name,
    required this.sheaves,
    required this.kind,
    this.stooks,
    required this.ways,
    required this.partitions,
    this.note,
  });

  final String name;
  final int sheaves;

  /// 'apart' for stooks all of different sizes, 'odd' for stooks all
  /// of odd size.
  final String kind;

  /// Exactly this many stooks, when asked.
  final int? stooks;

  /// Partitions that land it, by the walk of every one.
  final int ways;

  /// Partitions of the harvest, all told.
  final int partitions;

  /// One thing worth knowing about this harvest, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {4: 'four', 7: 'seven', 9: 'nine', 10: 'ten', 12: 'twelve'};

  /// Whether a standing of stooks meets the ask.
  bool meets(List<int> sizes) {
    if (stooks != null && sizes.length != stooks) return false;
    return kind == 'apart' ? sizes.toSet().length == sizes.length : sizes.every((s) => s.isOdd);
  }

  /// The task, told in words for the ledger.
  String get task {
    final count = stooks == null ? 'stooks' : 'exactly ${_words[stooks]} stooks';
    final what = kind == 'apart' ? 'of different sizes' : 'of odd size';
    return 'stand ${_words[sheaves]} sheaves in $count $what';
  }
}
