/// One fen: how many baskets to take, all free of swallowing.
class Fen {
  const Fen({
    required this.name,
    required this.take,
    required this.ways,
    this.note,
  });

  final String name;

  /// Baskets to take from the shelf.
  final int take;

  /// Free families of the sweep; nought on the hopeless fen, and
  /// the label says so.
  final int ways;

  /// One thing worth knowing about this fen, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'take $take baskets with none swallowing '
      'another';
}
