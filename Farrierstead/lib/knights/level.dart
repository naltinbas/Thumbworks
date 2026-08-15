import 'rules.dart';

/// One board on the sham: its size, how many knights to set, and what
/// the sweep found.
class Level {
  const Level({
    required this.name,
    required this.size,
    required this.knights,
    required this.ways,
    required this.settings,
    this.note,
  });

  final String name;

  /// Squares along a side.
  final int size;

  /// Knights to set.
  final int knights;

  /// Settings where none attacks another, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Settings of that many knights on the board, all of them.
  final int settings;

  /// One thing worth knowing about this board, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(size);

  static const _words = {3: 'three', 4: 'four', 5: 'five', 6: 'six', 8: 'eight', 9: 'nine', 13: 'thirteen', 18: 'eighteen'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'set ${word(knights)} knights on the ${word(size)} by ${word(size)} board so none attacks another';
}
