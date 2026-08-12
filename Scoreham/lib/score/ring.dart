/// One ring at the ham: its marks and how many good starts it hides.
class Ring {
  const Ring({
    required this.name,
    required this.marks,
    required this.goods,
    this.note,
  });

  final String name;

  /// The scores round the ring: 1 a notch up, -1 a wipe down.
  final List<int> marks;

  /// Good starts the ring holds, which is exactly how far it runs
  /// ahead; nought on the hopeless ring, and the label says so.
  final int goods;

  /// One thing worth knowing about this ring, said by the why.
  final String? note;

  bool get winnable => goods > 0;

  /// The task, told in words for the ledger.
  String get task => goods > 1
      ? 'find all $goods good starts'
      : goods == 1
          ? 'find the one good start'
          : 'find a good start';
}
