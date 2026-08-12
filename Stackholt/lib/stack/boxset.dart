/// One stack of the holt: its painted boxes and what the sweep
/// counts for them.
class BoxSet {
  const BoxSet({
    required this.name,
    required this.boxes,
    required this.opens,
    required this.ways,
    this.note,
  });

  final String name;

  /// Each box as three sleeves: front and back, left and right,
  /// top and bottom.
  final List<List<(String, String)>> boxes;

  /// How each box stands when the stack opens: never settled,
  /// and the checker holds it to that.
  final List<(int, int, int, int)> opens;

  /// Settlings the sweep counts, every box turned every way;
  /// nought on the hopeless stack, and the label says so.
  final int ways;

  /// One thing worth knowing about this stack, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get count => boxes.length;

  /// The task, told in words for the ledger.
  String get task => 'stand $count boxes so every wall shows '
      'every colour once';
}
