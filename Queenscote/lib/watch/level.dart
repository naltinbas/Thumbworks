import 'rules.dart';

/// One ask: so many queens on a board, to watch it, or to leave a set
/// count of squares unseen.
class Level {
  const Level({
    required this.name,
    required this.side,
    required this.queens,
    this.unseenAsked = 0,
    required this.ways,
    required this.placings,
    required this.aim,
    required this.note,
  });

  final String name;
  final int side;
  final int queens;

  /// The squares the ask wants left unseen: nought to watch the whole
  /// board.
  final int unseenAsked;

  /// How many placings land it, and how many placings there are, from
  /// the sweep.
  final int ways;
  final int placings;

  /// The placing the pointer works towards, squares in rising order, or
  /// null when none lands it.
  final List<int>? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  int get squares => side * side;

  /// Whether the queens at [placed] land the ask.
  bool meets(List<int> placed) => placed.length == queens && Rules.unseen(side, placed) == unseenAsked;

  /// The task, told in words for the ledger.
  String get task {
    final board = side == 8 ? 'the chessboard' : 'the ${_word(side)} by ${_word(side)}';
    final q = '${_word(queens)} queen${queens == 1 ? '' : 's'}';
    if (unseenAsked == 0) return 'set $q on $board so every square is seen';
    return 'set $q on $board so exactly ${_word(unseenAsked)} squares are left unseen';
  }

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight'][n];
}
