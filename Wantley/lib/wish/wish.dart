/// One wish list: a green of farms and the paths they ask for.
class Wish {
  const Wish({
    required this.name,
    required this.wishes,
    required this.ways,
    this.note,
  });

  final String name;

  /// Each farm's wished path count, in ring order.
  final List<int> wishes;

  /// Treadings of the sweep that land it; nought on the
  /// hopeless list, and the label says so.
  final int ways;

  /// One thing worth knowing about this list, said by the why.
  final String? note;

  int get farms => wishes.length;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final told = wishes.join(', ');
    return 'tread paths so the $farms farms get $told';
  }
}
