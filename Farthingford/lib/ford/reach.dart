/// One reach of the stream: where the banks start and what crossing
/// is asked.
class Reach {
  const Reach({
    required this.name,
    this.startA = (0, 1),
    this.startC = (1, 1),
    this.target,
    this.shallowerThan,
    required this.wades,
    this.note,
  });

  final String name;

  /// The banks at the off, left and right.
  final (int, int) startA;
  final (int, int) startC;

  /// The ford to reach, or null on the hopeless reach.
  final (int, int)? target;

  /// The hopeless asking: a crossing with depth under this.
  final int? shallowerThan;

  /// Mediants to the landing by the true walk; null when no wading
  /// ever meets the asking, and the label says so.
  final int? wades;

  /// One thing worth knowing about this reach, said by the why.
  final String? note;

  bool get winnable => wades != null;

  /// The task, told in words for the ledger.
  String get task {
    final ford = target;
    if (ford != null) return 'wade to ${ford.$1}/${ford.$2}';
    return 'cross shallower than ${_depth(shallowerThan!)}';
  }

  static String _depth(int q) => switch (q) {
        5 => 'fifths',
        7 => 'sevenths',
        _ => 'depth $q',
      };
}
