/// One low of the game: its posts, lines and layout.
class Low {
  const Low({
    required this.name,
    required this.posts,
    required this.lines,
    required this.spots,
    required this.ways,
    this.note,
  });

  final String name;

  /// Posts standing on the low.
  final int posts;

  /// The lines between them.
  final List<(int, int)> lines;

  /// Where each post stands, in fractions of the board.
  final List<(double, double)> spots;

  /// Graceful numberings the sweep counts; nought on the
  /// hopeless low, and the label says so.
  final int ways;

  /// One thing worth knowing about this low, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'number the $posts posts so the '
      '${lines.length} gaps run 1 to ${lines.length}';
}
