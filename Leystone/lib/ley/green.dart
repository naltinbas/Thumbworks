/// One green: how wide, and how many stones the mason asks for.
class Green {
  const Green({
    required this.name,
    required this.size,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Berths along each side.
  final int size;

  /// Stones asked for. On a winnable green this is the fullest ring
  /// the search finds; on the hopeless one it is a stone past it.
  final int asked;

  /// Sound rings of [asked] stones the green holds; 0 on the
  /// hopeless green, and the label says so.
  final int ways;

  /// One thing worth knowing about this green, said by the why.
  final String? note;

  bool get winnable => ways > 0;
}
