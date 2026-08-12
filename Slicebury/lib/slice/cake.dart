/// One cake: how many candles, and the slices asked.
class Cake {
  const Cake({
    required this.name,
    required this.candles,
    required this.slices,
    required this.ways,
    this.note,
  });

  final String name;

  /// Candles to set, exactly.
  final int candles;

  /// Slices asked, exactly.
  final int slices;

  /// Picks of the sweep that land; nought on the hopeless
  /// cake, and the label says so.
  final int ways;

  /// One thing worth knowing about this cake, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task =>
      'set $candles candles so the knife lines make exactly '
      '$slices slices';
}
