/// One hoard: the count two tiles must pay exactly.
class Hoard {
  const Hoard({
    required this.name,
    required this.target,
    required this.ways,
    this.note,
  });

  final String name;

  /// The count asked.
  final int target;

  /// Writings the dials reach; nought on the hopeless hoard,
  /// and the label says so.
  final int ways;

  /// One thing worth knowing about this hoard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'pay $target with two square tiles';
}
