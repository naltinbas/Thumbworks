/// One feast: how many guests sit, and the different counts
/// asked.
class Feast {
  const Feast({
    required this.name,
    required this.guests,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  final int guests;

  /// Different clink counts asked, exactly.
  final int asked;

  /// Feasts of the sweep that land; nought on the hopeless
  /// feast, and the label says so.
  final int ways;

  /// One thing worth knowing about this feast, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => asked == guests
      ? 'clink till all $guests counts differ'
      : asked == 1
          ? 'clink till every guest counts alike'
          : 'clink till exactly $asked different counts stand';
}
