/// One pitch on the fell: how many stone kinds, and how high the
/// wall is asked to climb.
class Pitch {
  const Pitch({
    required this.name,
    required this.kinds,
    required this.height,
    required this.reachable,
    this.note,
  });

  final String name;

  /// Stone kinds in the heap.
  final int kinds;

  /// Courses asked for.
  final int height;

  /// Whether any wall climbs that high; the label says so when
  /// none does.
  final bool reachable;

  /// One thing worth knowing about this pitch, said by the why.
  final String? note;

  bool get winnable => reachable;

  /// The task, told in words for the ledger.
  String get task => 'raise $height courses, no run laid twice over';
}
