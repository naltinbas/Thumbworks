import 'rules.dart';

/// One week on the sham: the days given, the days to fill, whether
/// every pair must be covered, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.given,
    required this.more,
    this.allPairs = false,
    required this.ways,
    required this.fillings,
    this.note,
  });

  final String name;

  /// The days already walked when the week opens.
  final List<Day> given;

  /// Days still to fill.
  final int more;

  /// Whether every pair must have walked together by the end.
  final bool allPairs;

  /// Fillings that land it, by the sweep; nought for the hopeless.
  final int ways;

  /// Fillings of the days to fill, all told: 280 to a day.
  final int fillings;

  /// One thing worth knowing about this week, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get days => given.length + more;

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four'};

  /// The task, told in words for the ledger.
  String get task {
    if (allPairs) {
      return 'walk the nine out for ${_words[days]} days in rows of three so every pair walks together once';
    }
    return more == 1
        ? 'walk the nine out for a ${['', 'first', 'second', 'third', 'fourth'][days]} day in rows of three, no pair walking together twice'
        : 'walk the nine out for ${_words[more]} more days in rows of three, no pair walking together twice';
  }
}
