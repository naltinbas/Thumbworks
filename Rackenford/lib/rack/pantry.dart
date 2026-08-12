/// One pantry: jars one to a top, and the racks offered.
class Pantry {
  const Pantry({
    required this.name,
    required this.top,
    required this.racks,
    required this.ways,
    this.note,
  });

  final String name;

  /// The jars run one to here.
  final int top;

  /// The racks offered.
  final int racks;

  /// Rackings of the sweep that land; nought on the hopeless
  /// pantry, and the label says so.
  final int ways;

  /// One thing worth knowing about this pantry, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'rack the jars one to $top on $racks racks '
      'with no jar above its divisor';
}
