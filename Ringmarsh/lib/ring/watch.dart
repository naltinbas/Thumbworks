/// One watch to set, as it ships.
class Watch {
  const Watch({
    required this.name,
    required this.span,
    required this.length,
    this.lockedPlaces = 0,
    this.lockedBits = 0,
    required this.ways,
    this.note,
  });

  final String name;

  /// How many lanterns a watchword spans.
  final int span;

  /// How many lanterns round the ring.
  final int length;

  /// Lanterns held fast, and how they are held.
  final int lockedPlaces;
  final int lockedBits;

  /// How many rings set the watch full, locks honoured, as the sweep
  /// counted them. Nought for the dead one.
  final int ways;

  final String? note;

  bool get winnable => ways > 0;

  int get words => 1 << span;

  bool isLocked(int place) => lockedPlaces & (1 << place) != 0;
}
