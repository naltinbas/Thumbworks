/// One hoard: how many nuts it starts with.
class Hoard {
  const Hoard({
    required this.name,
    required this.nuts,
    required this.winnable,
    this.note,
  });

  final String name;

  /// Nuts at the start. The opener may take up to one fewer.
  final int nuts;

  /// Whether the opener wins against perfect play. Written down here as
  /// well as worked out, so a test can hold the two against each other.
  final bool winnable;

  /// A sentence of its own this hoard has earned, said after the why, or
  /// null for the hoards whose story is the usual one.
  final String? note;
}
