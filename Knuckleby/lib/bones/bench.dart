/// One bench at the tavern: the dice to cut and what trade is asked.
class Bench {
  const Bench({
    required this.name,
    required this.facesOne,
    required this.facesTwo,
    this.lockedOne = false,
    this.evensOnly = false,
    this.otherThanStandard = true,
    required this.ways,
    this.note,
  });

  final String name;

  /// Sides of the two dice.
  final int facesOne;
  final int facesTwo;

  /// Whether the first die is fixed as the standard and only the
  /// second is cut.
  final bool lockedOne;

  /// Whether every pip must be even, which is the hopeless asking.
  final bool evensOnly;

  /// Whether the standard arrangement itself is refused as an
  /// answer, the task being the OTHER pair.
  final bool otherThanStandard;

  /// Matching pairs the sweep finds under this bench's law; 0 on
  /// the hopeless bench, and the label says so.
  final int ways;

  /// One thing worth knowing about this bench, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get lowPip => evensOnly ? 2 : 1;

  /// The task, told in words for the ledger.
  String get task {
    if (evensOnly) return 'match the table with every pip even';
    if (lockedOne) return 'cut the one partner that matches';
    return 'find a pair beside the standard';
  }
}
