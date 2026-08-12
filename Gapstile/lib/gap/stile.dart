/// One stile of the fence: how many pegs, and how many gap lengths
/// are asked to show.
class Stile {
  const Stile({
    required this.name,
    required this.pegs,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Distinct pegs the hoop must carry.
  final int pegs;

  /// Gap lengths asked to show.
  final int asked;

  /// Dials that do it, strides over rounds to twelfths; nought on
  /// the hopeless stile, and the label says so.
  final int ways;

  /// One thing worth knowing about this stile, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'peg $pegs and show exactly $asked gap '
      'length${asked == 1 ? '' : 's'}';
}
