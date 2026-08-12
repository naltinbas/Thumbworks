/// One ring at the stall: its beads, its dyes, and how many
/// necklaces are asked for.
class Ring {
  const Ring({
    required this.name,
    required this.beads,
    required this.dyes,
    required this.asked,
    required this.holds,
    this.note,
  });

  final String name;
  final int beads;
  final int dyes;

  /// Necklaces asked for. On the hopeless ring this is one past
  /// everything the ring can make.
  final int asked;

  /// Necklaces the ring holds in all, by both countings.
  final int holds;

  /// One thing worth knowing about this ring, said by the why.
  final String? note;

  bool get winnable => asked <= holds;

  /// The task, told in words for the ledger.
  String get task => 'string $asked necklaces, no two alike';
}
