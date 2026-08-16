import 'rules.dart';

/// One ask: a number to make from a run of consecutive odd numbers.
class Level {
  const Level({
    required this.name,
    required this.number,
    this.fromOne = false,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The number the run is to add to.
  final int number;

  /// Whether the run must start at 1.
  final bool fromOne;

  /// How many runs on the dials land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the run of [count] odd numbers from [first] lands the ask.
  bool meets(int first, int count) {
    if (first < 1 || first > Rules.firstMost || first.isEven || count < 1 || count > Rules.countMost) return false;
    if (fromOne && first != 1) return false;
    return Rules.sumBySquares(first, count) == number;
  }

  /// The run the pointer works towards, the sweep's first, the first
  /// odd number rising before the count, or null.
  (int, int)? get aim {
    for (var first = 1; first <= Rules.firstMost; first += 2) {
      for (var count = 1; count <= Rules.countMost; count++) {
        if (meets(first, count)) return (first, count);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task => fromOne
      ? 'add up odd numbers from 1 to make $number'
      : 'add up consecutive odd numbers to make $number';
}
