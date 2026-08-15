import 'rules.dart';

/// One set of calls on the sham: the calls and how many notes each is
/// to have, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.calls,
    required this.ways,
    required this.markings,
    this.note,
  });

  final String name;

  /// The calls, each with the count of notes its whistle is to have.
  final List<(String, int)> calls;

  /// Markings where no whistle starts another, by the sweep; nought for
  /// the hopeless.
  final int ways;

  /// Markings of whistles with the notes asked, all of them.
  final int markings;

  /// One thing worth knowing about these calls, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The counts of notes asked, in the calls' order.
  List<int> get lengths => [for (final (_, l) in calls) l];

  /// The calls whistled here have up to three notes.
  static const rules = Rules(3);

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five'};

  /// The lengths said in a row: 'one, two and two'.
  String get lengthsSaid {
    final words = lengths.map((l) => _words[l]!).toList();
    if (words.length == 1) return words.single;
    return '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';
  }

  /// The task, told in words for the ledger.
  String get task =>
      'give the ${_words[calls.length]} calls whistles of $lengthsSaid notes, none the start of another';
}
