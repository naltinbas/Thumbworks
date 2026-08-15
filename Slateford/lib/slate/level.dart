import 'rules.dart';

/// One slate on the sham: where it starts, which mark is yours, what
/// you are asked to reach, and what the walk found.
class Level {
  const Level({
    required this.name,
    required this.start,
    required this.side,
    required this.win,
    required this.from,
    required this.ways,
    required this.games,
    this.note,
  });

  final String name;

  /// The marks already on the slate when it opens.
  final Board start;

  /// Your mark: crosses or noughts. The book plays the other.
  final int side;

  /// Whether you are asked to win; otherwise a draw lands it.
  final bool win;

  /// Where from, for the task.
  final String from;

  /// Games against the book that land it, by the walk of every one.
  final int ways;

  /// Games against the book from this start, every way you can play.
  final int games;

  /// One thing worth knowing about this slate, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  String get mark => side == Rules.cross ? 'crosses' : 'noughts';

  /// The task, told in words for the ledger.
  String get task => '${win ? 'win' : 'draw'} as $mark $from';
}
