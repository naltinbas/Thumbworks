/// One shelf: how many books, and the steps down asked of it.
class Shelf {
  const Shelf({
    required this.name,
    required this.books,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Books on the shelf, one of every height.
  final int books;

  /// Steps down asked, exactly.
  final int asked;

  /// Orderings of the sweep that land it; nought on the hopeless
  /// shelf, and the label says so.
  final int ways;

  /// One thing worth knowing about this shelf, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'shelve $books books with exactly $asked '
      'step${asked == 1 ? '' : 's'} down';
}
