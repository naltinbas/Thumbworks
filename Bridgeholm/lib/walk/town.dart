/// One town of grounds and bridges, as it ships.
class Town {
  const Town({
    required this.name,
    required this.grounds,
    required this.spots,
    required this.bridges,
    this.bows = const [],
    required this.walkable,
    required this.oddGrounds,
    this.note,
  });

  final String name;

  /// The landings, by name.
  final List<String> grounds;

  /// Where each ground stands on the map, in nought-to-one widths and
  /// heights.
  final List<(double, double)> spots;

  /// The bridges, each joining two grounds. Two bridges may join the
  /// same pair; they are different bridges.
  final List<(int, int)> bridges;

  /// How far each bridge bows off its straight line, in landing radii,
  /// on top of the spread twins get. Bridges past the end bow nought.
  /// Purely a drawing matter, but the hit-testing shares it, so a
  /// bridge is tapped where it is seen.
  final List<double> bows;

  /// Whether any walk crosses every bridge once.
  final bool walkable;

  /// The grounds with an odd count of bridges, as the checker verified
  /// them.
  final List<int> oddGrounds;

  final String? note;

  int degree(int ground) {
    var count = 0;
    for (final (one, other) in bridges) {
      if (one == ground || other == ground) count++;
    }
    return count;
  }
}
