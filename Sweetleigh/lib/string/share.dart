/// One share on the sham: the string, the cuts allowed, and what
/// the sweep found.
class Share {
  const Share({
    required this.name,
    required this.sweets,
    required this.cuts,
    required this.ways,
    this.note,
  });

  final String name;
  final String sweets;

  /// Cuts allowed, at most.
  final int cuts;

  /// Sets of cuts that share fairly, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// One thing worth knowing about this share, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const kindNames = {'R': 'red', 'B': 'blue', 'G': 'green'};

  /// The task, told in words for the ledger.
  String get task {
    final counts = <String, int>{};
    for (final s in sweets.split('')) {
      counts[s] = (counts[s] ?? 0) + 1;
    }
    final told = counts.entries
        .map((e) => '${e.value} ${kindNames[e.key]}')
        .toList();
    final counted = told.length == 2
        ? '${told[0]} and ${told[1]}'
        : '${told.sublist(0, told.length - 1).join(', ')} and ${told.last}';
    return 'share $sweets, $counted, with at most $cuts '
        'cut${cuts == 1 ? '' : 's'}';
  }
}
