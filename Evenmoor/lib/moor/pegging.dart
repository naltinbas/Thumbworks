/// One pegging on the sham: how many pegs, how many posts asked to
/// land, and what the sweep found.
class Pegging {
  const Pegging({
    required this.name,
    required this.pegs,
    required this.asked,
    required this.ways,
    required this.placings,
    this.note,
  });

  final String name;
  final int pegs;

  /// Halfway posts asked to land on holes, exactly.
  final int asked;

  /// Placings that land it, by the sweep; nought for the hopeless.
  final int ways;

  /// Placings of that many pegs on the moor.
  final int placings;

  /// One thing worth knowing about this pegging, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {1: 'one', 3: 'three', 4: 'four', 5: 'five', 10: 'ten'};

  /// The task, told in words for the ledger.
  String get task {
    final posts = asked == 0
        ? 'no halfway post on a hole'
        : asked == 1
            ? 'exactly one halfway post on a hole'
            : 'exactly ${_words[asked] ?? '$asked'} halfway posts on holes';
    return 'set ${_words[pegs]} pegs with $posts';
  }
}
