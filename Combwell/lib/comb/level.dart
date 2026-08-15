import 'rules.dart';

/// One comb on the sham: what every line is to sum to, which cells are
/// given, and what the walk found.
class Level {
  const Level({
    required this.name,
    required this.sum,
    required this.given,
    required this.ways,
    this.note,
  });

  final String name;

  /// What every line is to sum to.
  final int sum;

  /// The numbers given, cell by cell, nought for a cell to fill.
  final List<int> given;

  /// Fillings that make every line sum alike, by the walk; nought for
  /// the hopeless.
  final int ways;

  /// One thing worth knowing about this comb, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(sum);

  /// Cells to fill.
  int get empties => given.where((v) => v == 0).length;

  static const _words = {4: 'four', 7: 'seven', 10: 'ten', 13: 'thirteen', 19: 'nineteen'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task => empties == Rules.cells
      ? 'fill the comb with the numbers one to nineteen so every line sums to $sum'
      : 'fill the ${word(empties)} empty cells with the numbers left so every line of the comb sums to $sum';
}
