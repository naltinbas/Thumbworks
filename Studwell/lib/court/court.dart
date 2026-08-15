/// One court on the sham: a side, a well, and what the sweep
/// found.
class Court {
  const Court({
    required this.name,
    required this.side,
    required this.wellX,
    required this.wellY,
    required this.ways,
    this.note,
  });

  final String name;
  final int side;
  final int wellX;
  final int wellY;

  /// Pavings that land, by the sweep; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this court, said by the why.
  final String? note;

  int get well => wellY * side + wellX;

  bool get winnable => ways > 0;

  int get elbows => (side * side - 1) ~/ 3;

  /// The task, told in words for the ledger.
  String get task {
    final court = side == 4 ? 'four-court' : 'five-court';
    return 'pave the $court round the well with $elbows elbows';
  }
}
