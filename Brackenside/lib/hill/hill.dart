/// One hill of the side: its size and the patch count asked.
class Hill {
  const Hill({
    required this.name,
    required this.side,
    required this.asked,
    required this.ways,
    this.opens = 'A',
    this.note,
  });

  final String name;

  /// Spots along each edge of the triangle.
  final int side;

  /// Rainbow patches asked to show.
  final int asked;

  /// Plantings of the sweep that land it; nought on the hopeless
  /// hill, and the label says so.
  final int ways;

  /// The plant the inside opens wearing: never a planting that
  /// already lands the asking, and the checker holds it to that.
  final String opens;

  /// One thing worth knowing about this hill, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'plant the side-$side hill to show exactly '
      '$asked three-plant patch${asked == 1 ? '' : 'es'}';
}
