/// One cote: its players and whatever rounds come already fixed.
class Cote {
  const Cote({
    required this.name,
    required this.players,
    this.given = const [],
    required this.ways,
    this.note,
  });

  final String name;

  /// Players in the ring.
  final int players;

  /// Rounds already fixed when the cote opens; these never
  /// unpair.
  final List<List<(int, int)>> given;

  /// Full fixtures of the sweep extending the given rounds;
  /// nought on the hopeless cote, and the label says so.
  final int ways;

  /// One thing worth knowing about this cote, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final rounds = players - 1;
    return given.isEmpty
        ? 'pair $players players over $rounds rounds, every pair '
            'meeting once'
        : given.length == 1
            ? 'finish the fixture of $players from its opening '
                'round'
            : 'finish the fixture of $players from its first '
                '${given.length} rounds';
  }
}
