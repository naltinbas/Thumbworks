import 'rules.dart';

/// One yard on the sham: its size, where the drain sits, and what the
/// walk found.
class Level {
  const Level({
    required this.name,
    required this.side,
    required this.drainRow,
    required this.drainCol,
    required this.drainWords,
    required this.ways,
    this.note,
  });

  final String name;

  /// Flags along a side.
  final int side;

  /// The drain's row and column.
  final int drainRow;
  final int drainCol;

  /// Where the drain sits, in words.
  final String drainWords;

  /// Pavings, by the walk; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get drain => drainRow * side + drainCol;

  /// Bricks to lay.
  int get bricks => (side * side - 1) ~/ 3;

  Rules get rules => Rules(side, drain);

  static const _words = {4: 'four', 5: 'five', 7: 'seven', 8: 'eight'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'pave the ${word(side)} by ${word(side)} yard with bricks three flags long, the drain $drainWords';
}
