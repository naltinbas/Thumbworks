/// One green of the village: its lanterns, the ropes already
/// strung, and how many closings the search counts.
class Green {
  const Green({
    required this.name,
    required this.lanterns,
    required this.given,
    required this.ways,
    this.note,
  });

  final String name;

  /// Lanterns standing on the green.
  final int lanterns;

  /// Ropes already strung when the green opens; these never lift.
  final List<(int, int, int)> given;

  /// Closings the search counts from the given ropes; nought on
  /// the hopeless green, and the label says so.
  final int ways;

  /// One thing worth knowing about this green, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final ropes = lanterns * (lanterns - 1) ~/ 6;
    final left = ropes - given.length;
    return given.isEmpty
        ? 'string $left rope${left == 1 ? '' : 's'} so every pair '
            'of $lanterns lanterns shares exactly one'
        : 'string the $left rope${left == 1 ? '' : 's'} that '
            'close the green of $lanterns';
  }
}
