/// One ground, as it ships.
class Ground {
  const Ground({
    required this.name,
    required this.posts,
    required this.paths,
    required this.spots,
    required this.catStart,
    required this.rounds,
    this.note,
  });

  final String name;
  final int posts;
  final List<(int, int)> paths;

  /// Where each post stands, in nought-to-one widths and heights.
  final List<(double, double)> spots;

  /// Where the cat begins.
  final int catStart;

  /// The worst-case rounds to the catch from there with best play, or
  /// null where the mouse escapes forever.
  final int? rounds;

  final String? note;

  bool get winnable => rounds != null;
}
