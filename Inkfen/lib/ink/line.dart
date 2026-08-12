/// One line of bunting: its posts laid out on the green, its
/// strings, and the pot of inks allowed.
class Line {
  const Line({
    required this.name,
    required this.spots,
    required this.strings,
    required this.pot,
    required this.ways,
    this.note,
  });

  final String name;

  /// Where each post stands, in fractions of the board.
  final List<(double, double)> spots;

  /// Every string, as a pair of posts.
  final List<(int, int)> strings;

  /// How many inks the pot holds.
  final int pot;

  /// Inkings of the sweep that land; nought on the hopeless
  /// line, and the label says so.
  final int ways;

  /// One thing worth knowing about this line, said by the why.
  final String? note;

  int get posts => spots.length;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'ink the ${strings.length} strings from a '
      'pot of $pot so none share a post in one ink';
}
