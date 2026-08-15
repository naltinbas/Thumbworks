/// One yard on the sham: who threw whom, what is asked, and what the
/// walk of every ordering found.
class Level {
  const Level({
    required this.name,
    required this.wrestlers,
    required this.bouts,
    required this.ring,
    required this.ways,
    required this.orderings,
    this.note,
  });

  final String name;
  final int wrestlers;

  /// (a, b) for every bout, a having thrown b.
  final List<(int, int)> bouts;

  /// Whether the line must close into a ring, the last throwing the first.
  final bool ring;

  /// Orderings that land it, by the walk of every one.
  final int ways;

  /// Orderings of the yard, all told.
  final int orderings;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const names = ['Ash', 'Bram', 'Cole', 'Dane', 'Eli', 'Fenn'];

  static const _words = {4: 'four', 5: 'five', 6: 'six'};

  /// The task, told in words for the ledger.
  String get task => ring
      ? 'close the ${_words[wrestlers]} into a ring, each throwing the next and the last the first'
      : 'line the ${_words[wrestlers]} up so each threw the next';
}
