/// One riddling job, as it ships.
class Mesh {
  const Mesh({
    required this.name,
    required this.strands,
    required this.combs,
    required this.winnable,
    this.note,
  });

  final String name;

  /// How many strands hang in the frame.
  final int strands;

  /// How many combs the frame holds.
  final int combs;

  /// Whether any weave of so many combs riddles clean.
  final bool winnable;

  final String? note;

  int get grists => 1 << strands;
}
