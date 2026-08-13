/// One tour: the posts its round must walk.
class Tour {
  const Tour({
    required this.name,
    required this.posts,
    required this.ways,
    this.note,
  });

  final String name;

  /// Posts in the round, exactly.
  final int posts;

  /// Rounds of the sweep that stand; nought on the hopeless
  /// tour, and the label says so.
  final int ways;

  /// One thing worth knowing about this tour, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task =>
      'walk a closed round through exactly $posts posts';
}
