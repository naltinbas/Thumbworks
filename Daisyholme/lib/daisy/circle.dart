/// One circle: how many people stand in it, and what is given.
class Circle {
  const Circle({
    required this.name,
    required this.people,
    this.given = const [],
    required this.ways,
    this.note,
  });

  final String name;

  final int people;

  /// Friendships given and held, as pairs.
  final List<(int, int)> given;

  /// Wirings of the sweep that land it; nought on the hopeless
  /// circle, and the label says so.
  final int ways;

  /// One thing worth knowing about this circle, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final held = given.isEmpty
        ? ''
        : ', the heart\'s ${given.length} friendships given';
    return 'befriend $people people till every pair shares '
        'exactly one friend$held';
  }
}
