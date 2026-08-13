/// One house: how many windows it has, and the turns asked.
class House {
  const House({
    required this.name,
    required this.count,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// The windows round the house.
  final int count;

  /// Turns to darkness asked, exactly.
  final int asked;

  /// Diallings of the sweep that land; nought on the hopeless
  /// house, and the label says so.
  final int ways;

  /// One thing worth knowing about this house, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task =>
      'dial the $count windows to go dark in exactly $asked '
      'turn${asked == 1 ? '' : 's'}';
}
