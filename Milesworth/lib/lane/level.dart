/// One lane on the sham: the count asked, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.count,
    required this.ways,
    required this.runs,
    this.note,
  });

  final String name;

  /// The count to make, and the last milestone on the lane.
  final int count;

  /// Runs that add to the count, by the sweep; nought for the hopeless.
  final int ways;

  /// Runs of two or more on the lane, all told.
  final int runs;

  /// One thing worth knowing about this lane, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {13: 'thirteen', 15: 'fifteen', 16: 'sixteen', 21: 'twenty-one', 45: 'forty-five'};

  /// The task, told in words for the ledger.
  String get task => 'mark a run of two or more milestones adding to ${_words[count] ?? '$count'}';
}
