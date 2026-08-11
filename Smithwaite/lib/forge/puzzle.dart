/// A run of tavern rings on the smith's bar.
///
/// Each ring is either on the bar or off it. The first ring comes on or off
/// whenever you like. Any other ring moves only when the ring just before
/// it is on and every ring before that is off: the cords allow nothing
/// else. The puzzle is worked when every ring is off and the bar slides
/// free.
class Puzzle {
  const Puzzle({
    required this.name,
    required this.rings,
    required this.fewest,
    this.laid,
    this.note,
  });

  final String name;

  /// How many rings the smith forged on.
  final int rings;

  /// The fewest moves that free the bar from how it is handed over.
  /// Written down here as well as worked out, so a test can hold the two
  /// against each other.
  final int fewest;

  /// How the rings lie when the smith hands it over, as bits, or null for
  /// the usual way: every ring on.
  final int? laid;

  /// A sentence of its own this puzzle has earned, said after the why, or
  /// null for the puzzles whose story is the usual one.
  final String? note;

  int get start => laid ?? (1 << rings) - 1;
}
