/// One worth: how many weights to choose, all parcels distinct.
class Worth {
  const Worth({
    required this.name,
    required this.choose,
    required this.ways,
    this.note,
  });

  final String name;

  /// Weights to choose from the rack.
  final int choose;

  /// Clean choices of the sweep; nought on the hopeless worth,
  /// and the label says so.
  final int ways;

  /// One thing worth knowing about this worth, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'choose $choose weights with no two '
      'parcels balancing';
}
