/// One yard: its size and the seams asked of a full laying.
class Yard {
  const Yard({
    required this.name,
    required this.width,
    required this.height,
    this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  final int width;
  final int height;

  /// Seams asked, exactly; null for any full laying at all.
  final int? asked;

  /// Full layings of the sweep that land it; nought on the
  /// hopeless yard, and the label says so.
  final int ways;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => asked == null
      ? 'brick the $width by $height yard whole'
      : asked == 0
          ? 'brick the $width by $height yard with no seam'
          : 'brick the $width by $height yard with exactly '
              '$asked seam${asked == 1 ? '' : 's'}';
}
