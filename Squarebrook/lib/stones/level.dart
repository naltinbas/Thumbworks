import 'rules.dart';

/// One number on the sham: the number to make, how many stones to make
/// it of, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.number,
    required this.count,
    required this.ways,
    required this.pickings,
    this.note,
  });

  final String name;

  /// The number to make.
  final int number;

  /// Stones to make it of.
  final int count;

  /// Pickings that make it, by the sweep; nought for the hopeless.
  final int ways;

  /// Pickings of that many stones from those up to the number, all of
  /// them.
  final int pickings;

  /// One thing worth knowing about this number, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  static const _words = {2: 'two', 3: 'three', 4: 'four', 7: 'seven', 12: 'twelve', 23: 'twenty-three', 50: 'fifty', 99: 'ninety-nine'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task => 'make ${word(number)} of exactly ${word(count)} square stones';
}
