/// One grind: the nought count asked of the mill.
class Grind {
  const Grind({
    required this.name,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Trailing noughts asked, exactly.
  final int asked;

  /// Windings that land it, to the mill's furthest; nought on
  /// the hopeless grind, and the label says so.
  final int ways;

  /// One thing worth knowing about this grind, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'wind the mill so the factorial ends in '
      'exactly $asked nought${asked == 1 ? '' : 's'}';
}
