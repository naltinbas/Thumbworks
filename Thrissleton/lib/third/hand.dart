/// One hand: five stones, an asked count of thirds, and
/// perhaps a stone held fast.
class Hand {
  const Hand({
    required this.name,
    required this.asked,
    required this.opens,
    this.locked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Thirds asked, exactly.
  final int asked;

  /// The faces the stones open on.
  final List<int> opens;

  /// A stone held fast, as (stone, face), or null.
  final (int, int)? locked;

  /// Hands of the sweep that land it; nought on the hopeless
  /// hand, and the label says so.
  final int ways;

  /// One thing worth knowing about this hand, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final held =
        locked == null ? '' : ', the ${locked!.$2} held fast';
    return 'dial the stones to exactly $asked '
        'third${asked == 1 ? '' : 's'}$held';
  }
}
