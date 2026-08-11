/// One party of people to be paired, as it ships.
class Party {
  const Party({
    required this.name,
    required this.names,
    required this.prefs,
    required this.sided,
    required this.settles,
    this.note,
  });

  final String name;

  /// The people, by their short names, person nought first.
  final List<String> names;

  /// Each person's ranking, best first.
  final List<List<int>> prefs;

  /// Whether the party is two-sided: the first half only rank the
  /// second and back again. A one-sided party ranks everyone.
  final bool sided;

  /// How many of all the pairings sit settled. Nought for the dead one.
  final int settles;

  final String? note;

  bool get winnable => settles > 0;

  int get people => names.length;
}
