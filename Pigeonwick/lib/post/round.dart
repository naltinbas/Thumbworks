/// One round of the post: how many letters, and how many may go
/// home.
class Round {
  const Round({
    required this.name,
    required this.letters,
    required this.home,
    required this.ways,
    this.note,
  });

  final String name;

  /// Letters on the round, one hole apiece.
  final int letters;

  /// Letters that must end up home, exactly.
  final int home;

  /// Full rounds of the sweep that do it; nought on the hopeless
  /// round, and the label says so.
  final int ways;

  /// One thing worth knowing about this round, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => home == 0
      ? 'post all $letters letters with none home'
      : 'post all $letters letters with exactly $home home';
}
