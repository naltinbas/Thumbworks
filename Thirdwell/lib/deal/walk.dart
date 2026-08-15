/// One walk on the sham: the counter, the place asked, the deals
/// allowed, and what the sweep found.
class Walk {
  const Walk({
    required this.name,
    required this.chosen,
    required this.place,
    required this.deals,
    required this.ways,
    this.note,
  });

  final String name;

  /// The counter that must walk, nought to twenty-six by its start.
  final int chosen;

  /// The place asked, nought from the top.
  final int place;

  /// Deals allowed.
  final int deals;

  /// Runs of placings that land it, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// One thing worth knowing about this walk, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 3: 'three'};

  /// The task, told in words for the ledger.
  String get task =>
      'walk counter ${chosen + 1} to place ${place + 1} in ${_words[deals]} deals';
}
