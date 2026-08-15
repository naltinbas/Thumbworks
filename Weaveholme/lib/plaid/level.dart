import 'rules.dart';

/// One plaid on the sham: its size, which rows are given, and what the
/// walk found.
class Level {
  const Level({
    required this.name,
    required this.size,
    required this.given,
    required this.ways,
    required this.fillings,
    this.note,
  });

  final String name;

  /// Rows and columns.
  final int size;

  /// The rows woven already, top down, as bits; the rest are to weave.
  final List<int> given;

  /// Fillings where every two rows agree in half, by the walk or the
  /// sweep; nought for the hopeless.
  final int ways;

  /// Fillings of the free squares, all of them: two to their count.
  final int fillings;

  /// One thing worth knowing about this plaid, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(size);

  int get freeRows => size - given.length;

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 6: 'six', 8: 'eight'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task {
    final agree = 'agree in exactly ${word(size ~/ 2)} square${size ~/ 2 == 1 ? '' : 's'}';
    return given.isEmpty
        ? 'weave the ${word(size)} by ${word(size)} plaid so every two rows $agree'
        : 'weave the last ${word(freeRows)} rows of the ${word(size)} by ${word(size)} plaid so every two rows $agree';
  }
}
