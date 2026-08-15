import 'rules.dart';

/// One cellar on the sham: how many casks, how many questions, and what
/// the sweep found.
class Level {
  const Level({
    required this.name,
    required this.casks,
    required this.questions,
    required this.ways,
    required this.cuts,
    this.note,
  });

  final String name;

  /// Casks in the row.
  final int casks;

  /// Questions allowed.
  final int questions;

  /// First cuts after which the questions still suffice, by the sweep;
  /// nought for the hopeless.
  final int ways;

  /// First cuts, all of them: one fewer than the casks.
  final int cuts;

  /// One thing worth knowing about this cellar, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  static const _words = {3: 'three', 4: 'four', 5: 'five', 7: 'seven', 8: 'eight', 9: 'nine', 16: 'sixteen', 20: 'twenty', 100: 'a hundred'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'find the coin among ${word(casks)} casks in ${word(questions)} questions, whatever the cellarman answers';
}
