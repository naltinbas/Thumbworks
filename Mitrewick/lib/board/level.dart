import 'rules.dart';

/// One board on the sham: its side, how many bishops, which are given,
/// and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.side,
    required this.bishops,
    this.given = const [],
    required this.ways,
    required this.settings,
    this.note,
  });

  final String name;
  final int side;

  /// Bishops to stand, the given ones among them.
  final int bishops;

  /// Bishops already standing when the board opens; they never lift.
  final List<Square> given;

  /// Settings that land it, by the sweep; nought for the hopeless.
  final int ways;

  /// Settings of the free bishops, all told.
  final int settings;

  /// One thing worth knowing about this board, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven', 8: 'eight'};

  /// The task, told in words for the ledger.
  String get task {
    final board = 'the ${_words[side]}-by-${_words[side]} board';
    final held = given.isEmpty ? '' : ', one held in the corner';
    return 'stand ${_words[bishops]} bishops on $board with none on another\'s diagonal$held';
  }
}
