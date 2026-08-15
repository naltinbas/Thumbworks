import 'rules.dart';

/// One ledger on the sham: the two numbers, how many rows to keep if
/// that is asked, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.first,
    required this.second,
    this.exactly,
    required this.ways,
    required this.keepings,
    this.note,
  });

  final String name;

  /// The number halved, and the number doubled.
  final int first;
  final int second;

  /// Rows to keep, when the ledger asks for so many and no more.
  final int? exactly;

  /// Keepings whose doubles add to the product, by the sweep; nought
  /// for the hopeless.
  final int ways;

  /// Keepings of the rows, all of them, or all of so many rows.
  final int keepings;

  /// One thing worth knowing about this ledger, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(first, second);

  static const _words = {2: 'two', 3: 'three'};

  /// The task, told in words for the ledger.
  String get task => exactly == null
      ? 'keep rows of the halving of $first by $second so the doubles kept add to ${first * second}'
      : 'keep exactly ${_words[exactly] ?? '$exactly'} rows of the halving of $first by $second so the doubles kept add to ${first * second}';
}
