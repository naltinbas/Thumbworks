/// One yard on the sham: how many slabs, what kerb, and what the
/// sweep found.
class Yard {
  const Yard({
    required this.name,
    required this.slabs,
    required this.asked,
    required this.ways,
    required this.placings,
    this.note,
  });

  final String name;
  final int slabs;

  /// The kerb asked for, exactly.
  final int asked;

  /// Placings that land, by the sweep; nought for the hopeless.
  final int ways;

  /// Joined placings of that many slabs on the yard.
  final int placings;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'lay $slabs slabs joined, in a kerb of exactly $asked';
}
