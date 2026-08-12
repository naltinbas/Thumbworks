/// One moor: how many stones, how many paints.
class Moor {
  const Moor({
    required this.name,
    required this.stones,
    required this.paints,
    required this.ways,
    this.note,
  });

  final String name;

  /// Stones in the row, numbered one and up.
  final int stones;

  /// Paints on hand.
  final int paints;

  /// Clean paintings the sweep counts; nought on the hopeless
  /// moor, and the label says so.
  final int ways;

  /// One thing worth knowing about this moor, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'paint stones 1 to $stones with $paints '
      'paint${paints == 1 ? '' : 's'} and no bad sum';
}
