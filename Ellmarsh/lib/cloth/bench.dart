/// One bench: the two bolts as the mercer left them.
class Bench {
  const Bench({
    required this.name,
    required this.long,
    required this.short,
    required this.winnable,
    this.note,
  });

  final String name;

  /// The bolts, in ells.
  final int long;
  final int short;

  /// Whether the opener holds the bench against perfect play. Written
  /// down here as well as worked out, so a test can hold the two against
  /// each other.
  final bool winnable;

  /// A sentence of its own this bench has earned, said after the why, or
  /// null for the benches whose story is the usual one.
  final String? note;
}
