import 'rules.dart';

/// One board on the sham: its size, how many kings to set, and what
/// the sweep found.
class Level {
  const Level({
    required this.name,
    required this.size,
    required this.kings,
    required this.ways,
    required this.settings,
    this.note,
  });

  final String name;

  /// Squares along a side.
  final int size;

  /// Kings to set.
  final int kings;

  /// Settings where none attacks another, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Settings of that many kings on the board, all of them.
  final int settings;

  /// One thing worth knowing about this board, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(size);

  static const _words = {3: 'three', 4: 'four', 5: 'five', 6: 'six', 9: 'nine'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'set ${word(kings)} kings on the ${word(size)} by ${word(size)} board so none attacks another';
}
