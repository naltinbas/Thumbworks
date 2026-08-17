import 'rules.dart';

/// One ask: a row of houses, and the walking the pump is to come down
/// to.
class Level {
  const Level({
    required this.name,
    required this.houses,
    required this.walk,
    required this.under,
    required this.ways,
    required this.note,
  });

  final String name;

  /// Where the houses stand, in order along the lane.
  final List<int> houses;

  /// The walking the ask allows.
  final int walk;

  /// Whether the ask wants the walking under that, which nothing does.
  final bool under;

  /// How many spots land it, from the sweep.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the pump at [spot] lands the ask.
  bool meets(int spot) {
    if (!Rules.onLane(spot)) return false;
    final got = Rules.walk(houses, spot);
    return under ? got < walk : got == walk;
  }

  /// The spots the walking is least at.
  List<int> get best => Rules.bestSpots(houses);

  /// The nearest of them to the pump's start, which is what the pointer
  /// works towards.
  int? get aim {
    if (!winnable) return null;
    var nearest = best.first;
    for (final spot in best) {
      if ((spot - Rules.start).abs() < (nearest - Rules.start).abs()) {
        nearest = spot;
      }
    }
    return nearest;
  }

  /// The steps the pump takes to reach it.
  int? get fewest => aim == null ? null : (aim! - Rules.start).abs();

  /// The task, told in words for the ledger.
  String get task => under
      ? 'stand the pump where the walking comes to less than $walk'
      : 'stand the pump where the walking comes to $walk';
}
