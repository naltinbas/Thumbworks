/// One yard: its birds, where the arrows start, and what crowning
/// the task asks.
class Yard {
  const Yard({
    required this.name,
    required this.birds,
    required this.start,
    this.wantCount,
    this.wantOnly,
    required this.par,
    this.note,
  });

  final String name;
  final int birds;

  /// The arrows at the off, one bit a pair. All bits set is the
  /// pecking order: every bird pecks everything below it.
  final int start;

  /// Crown exactly this many, or null.
  final int? wantCount;

  /// Crown this bird and nobody else, or null.
  final int? wantOnly;

  /// Fewest flips that do it; null when no flipping of any yard
  /// ever does, and the label says so.
  final int? par;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => par != null;

  bool goalMet(List<int> kings) {
    final only = wantOnly;
    if (only != null) return kings.length == 1 && kings.first == only;
    return kings.length == wantCount;
  }

  /// The task, told in words for the ledger.
  String get task {
    final only = wantOnly;
    if (only != null) return 'crown the bantam alone';
    if (wantCount == birds) return 'crown all $wantCount';
    return 'crown exactly $wantCount';
  }
}
