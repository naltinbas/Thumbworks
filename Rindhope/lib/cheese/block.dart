/// A block of cheese, and whose bite comes first.
///
/// The block stands so many crumbs wide and tall, and the crumb in the
/// bottom-left corner is mouldy. A bite takes a crumb and everything above
/// and to the right of it in one square mouthful. Two mice bite in turn,
/// and whoever ends up taking the mouldy crumb has lost.
class Block {
  const Block({
    required this.name,
    required this.width,
    required this.height,
    required this.fewest,
    this.mouseFirst = false,
    this.note,
  });

  final String name;

  /// Crumbs across and up.
  final int width;
  final int height;

  /// The fewest bites of the player's own that force the win, with the
  /// grey mouse delaying all it can, or null on the block where the grey
  /// mouse bites first and cannot be beaten at all. Written down here as
  /// well as worked out, so a test can hold the two against each other.
  final int? fewest;

  /// Whether the grey mouse bites first.
  final bool mouseFirst;

  /// A sentence of its own this block has earned, said after the why, or
  /// null for the blocks whose story is the usual one.
  final String? note;

  bool get hopeless => fewest == null;

  /// The whole block: every column at full height.
  List<int> get whole => List<int>.filled(width, height);
}
