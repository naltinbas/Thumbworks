/// One village of the fen: its houses, roads, and the spread of
/// debts the level opens on.
class Village {
  const Village({
    required this.name,
    required this.houseNames,
    required this.roads,
    required this.spots,
    required this.spread,
    required this.fewest,
    this.note,
  });

  final String name;

  /// Each house's name, in house order; the first house is the
  /// bank the burning starts from.
  final List<String> houseNames;

  final List<(int, int)> roads;

  /// Where each house stands, in fractions of the board.
  final List<(double, double)> spots;

  /// The pounds each house opens holding; in debt below nought.
  final List<int> spread;

  /// The proven fewest moves to a settlement; null on the
  /// hopeless village, and the label says so.
  final int? fewest;

  /// One thing worth knowing about this village, said by the why.
  final String? note;

  int get houses => houseNames.length;

  bool get winnable => fewest != null;

  int get total => spread.reduce((a, b) => a + b);

  /// The task, told in words for the ledger.
  String get task {
    final owing =
        spread.where((p) => p < 0).fold(0, (a, p) => a - p);
    return 'settle $owing pound${owing == 1 ? '' : 's'} of debt '
        'with $total clear';
  }
}
