/// One down of the game: its posts and the ropes asked of it.
class Down {
  const Down({
    required this.name,
    required this.posts,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Posts standing on the down.
  final int posts;

  /// Ropes asked, none of them knotting a triangle.
  final int asked;

  /// Tetherings of the sweep that do it; nought on the hopeless
  /// down, and the label says so.
  final int ways;

  /// One thing worth knowing about this down, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'tie $asked rope${asked == 1 ? '' : 's'} '
      'between $posts posts and knot no triangle';
}
