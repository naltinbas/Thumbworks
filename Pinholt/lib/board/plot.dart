/// One plot on the sham: how many pins, how many frames asked,
/// and what the sweep found.
class Plot {
  const Plot({
    required this.name,
    required this.pins,
    required this.asked,
    required this.ways,
    required this.placings,
    this.note,
  });

  final String name;
  final int pins;

  /// Frames asked for, exactly.
  final int asked;

  /// Placings that land, by the sweep; nought for the hopeless.
  final int ways;

  /// Placings of that many pins with no three in a line.
  final int placings;

  /// One thing worth knowing about this plot, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {0: 'no', 1: 'exactly one', 3: 'exactly three'};

  /// The task, told in words for the ledger.
  String get task =>
      'set $pins pins, no three in a line, holding '
      '${_words[asked] ?? 'exactly $asked'} frame${asked == 1 ? '' : 's'}';
}
