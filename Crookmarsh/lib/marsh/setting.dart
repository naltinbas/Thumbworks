/// One marsh setting: how many posts, and how many true frames
/// are asked to show.
class Setting {
  const Setting({
    required this.name,
    required this.posts,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Posts the marsh must carry, none three to a line.
  final int posts;

  /// True frames asked to show.
  final int asked;

  /// Clear settings of the sweep that do it; nought on the
  /// hopeless marsh, and the label says so.
  final int ways;

  /// One thing worth knowing about this marsh, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'stand $posts posts, none three to a line, '
      'showing $asked true frame${asked == 1 ? '' : 's'}';
}
