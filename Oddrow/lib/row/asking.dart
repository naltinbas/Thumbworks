/// One asking: the odd count a row must hold.
class Asking {
  const Asking({
    required this.name,
    required this.odds,
    required this.ways,
    this.note,
  });

  final String name;

  /// Odd entries asked, exactly.
  final int odds;

  /// Rows of the wall that hold it; nought on the hopeless
  /// asking, and the label says so.
  final int ways;

  /// One thing worth knowing about this asking, said by the
  /// why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task =>
      'wind to a row holding exactly $odds odd '
      'number${odds == 1 ? '' : 's'}';
}
