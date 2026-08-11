/// One moor: so many plots a side, a mill wanted in every file.
class Moor {
  const Moor({
    required this.name,
    required this.size,
    required this.possible,
    required this.ways,
    this.note,
  });

  final String name;

  /// Plots a side, and mills wanted.
  final int size;

  /// Whether any setting exists. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final bool possible;

  /// How many settings there are, reflections and turns counted apart.
  final int ways;

  /// A sentence of its own this moor has earned, said after the why, or
  /// null for the moors whose story is the usual one.
  final String? note;
}
