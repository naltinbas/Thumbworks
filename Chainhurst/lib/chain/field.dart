/// One field of the hurst: how many stones, and how many bare
/// chains are asked to show.
class Field {
  const Field({
    required this.name,
    required this.stones,
    required this.asked,
    required this.offRow,
    required this.ways,
    this.note,
  });

  final String name;

  /// Stones the field must carry.
  final int stones;

  /// Bare chains asked to show.
  final int asked;

  /// Whether the asking bars all-in-one-row placings.
  final bool offRow;

  /// Placings of the sweep that do it; nought on the hopeless
  /// field, and the label says so.
  final int ways;

  /// One thing worth knowing about this field, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'set $stones stones'
      '${offRow ? ', not all in one row,' : ''} showing '
      '$asked bare chain${asked == 1 ? '' : 's'}';
}
