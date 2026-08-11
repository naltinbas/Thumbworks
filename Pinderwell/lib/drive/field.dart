/// A stray ewe, a field, and the pen in the corner.
///
/// The ewe stands so many paces east and so many paces north of the pen. A
/// push drives her any number of paces west, any number south, or the same
/// number of both at once, the way a ewe actually gives ground: straight
/// away from you or along the wall. Two herders push in turn, and the push
/// that puts her in the pen takes the fee.
class Field {
  const Field({
    required this.name,
    required this.east,
    required this.north,
    required this.fewest,
  });

  final String name;

  /// Where the ewe starts: paces east and north of the pen.
  final int east;
  final int north;

  /// The fewest pushes of the player's own that force the pen, with the
  /// pinder giving the most ground he can, or null on the field where the
  /// pinder cannot be beaten at all. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final int? fewest;

  bool get hopeless => fewest == null;

  /// How much field to draw: a couple of paces of grass beyond the ewe.
  int get across => east + 3;
  int get down => north + 3;
}
