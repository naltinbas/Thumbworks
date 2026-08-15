/// One stack on the sham: how many books, how far the top must hang
/// out, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.books,
    required this.asked,
    required this.ways,
    required this.stacks,
    this.note,
  });

  final String name;
  final int books;

  /// The overhang asked, in twenty-fourths of a book.
  final int asked;

  /// Standing stacks on the grid that hang out that far, by the sweep.
  final int ways;

  /// Stacks on the grid, all told: twenty-five offsets to a book.
  final int stacks;

  /// One thing worth knowing about this stack, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five'};

  /// The overhang asked, in words.
  String get askedWords => switch (asked) {
        12 => 'half a book',
        18 => 'three quarters of a book',
        24 => 'a whole book',
        27 => 'a book and an eighth',
        _ => '$asked twenty-fourths of a book',
      };

  /// The task, told in words for the ledger.
  String get task =>
      'lean ${_words[books]} book${books == 1 ? '' : 's'} over the desk edge so the top hangs out $askedWords';
}
