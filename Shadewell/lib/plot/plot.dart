/// One plot to shade, as it ships.
class Plot {
  const Plot({
    required this.name,
    required this.wide,
    required this.high,
    required this.rowTallies,
    required this.colTallies,
    required this.solutions,
    this.picture,
    this.note,
  });

  final String name;
  final int wide;
  final int high;

  /// The tallies, top row first and left column first.
  final List<List<int>> rowTallies;
  final List<List<int>> colTallies;

  /// How many pictures the tallies accept, as the stacking counted.
  final int solutions;

  /// The one picture, where there is one. Row bitmasks, low bit left.
  final List<int>? picture;

  final String? note;

  bool get winnable => solutions > 0;

  int get rowsAsk => [
        for (final tally in rowTallies) ...tally,
      ].reduce((a, b) => a + b);

  int get colsAsk => [
        for (final tally in colTallies) ...tally,
      ].reduce((a, b) => a + b);
}
