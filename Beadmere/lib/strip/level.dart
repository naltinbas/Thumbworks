import 'rules.dart';

/// One ask: a strip of so many beads, and the two repeats it is to have
/// without the third.
class Level {
  const Level({
    required this.name,
    required this.beads,
    required this.first,
    required this.second,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// How many beads the strip holds.
  final int beads;

  /// The two repeats wanted.
  final int first, second;

  /// How many strips land it, from the sweep.
  final int ways;

  /// The cheapest strip that lands it, from the sweep; empty when none
  /// does.
  final List<int> aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// The repeat the two would force on a long enough strip.
  int get forced => Rules.gcdOf(first, second);

  /// The length at which they would force it.
  int get bound => Rules.bound(first, second);

  /// Whether [strip] lands the ask: both repeats and not the one they
  /// would force.
  bool meets(List<int> strip) =>
      strip.length == beads &&
      Rules.repeats(strip, first) &&
      Rules.repeats(strip, second) &&
      !Rules.repeats(strip, forced);

  /// The taps the cheapest strip takes from a strip of light beads.
  int? get fewest => winnable
      ? aim.where((bead) => bead == Rules.dark).length
      : null;

  int get strips => Rules.howManyStrips(beads);

  /// The task, told in words for the ledger.
  String get task => 'string $beads beads that repeat every $first and every '
      '$second without repeating every $forced';
}
