import 'maker.dart';

/// One stretch of the book: a size, and how hard its puzzles have to be.
class Chapter {
  const Chapter({
    required this.size,
    required this.leastPasses,
    required this.title,
  });

  final int size;

  /// The floor on [Puzzle.passes], which is how many times the solver had to
  /// come back round the lines.
  final int leastPasses;

  /// What this stretch is called, for the line under the puzzle number.
  final String title;
}

/// The order the puzzles come in.
///
/// The book is endless and holds nothing. A puzzle number is its own seed, so
/// puzzle forty-one is the same grid on every phone that ever asks for it,
/// worked out in a couple of milliseconds when it is wanted rather than
/// shipped in the app. Nothing is stored but the number the player has got to.
///
/// The climb is in two directions at once. The grid grows, which is more to
/// look at and longer lines to reason about; and the floor on the solver's
/// passes rises, which asks for deductions that only become available after
/// other deductions. The second is the one that makes the later puzzles feel
/// different rather than merely bigger.
class Book {
  const Book._();

  static const _chapters = <int, Chapter>{
    1: Chapter(size: 5, leastPasses: 1, title: 'the small ones'),
    6: Chapter(size: 5, leastPasses: 3, title: 'small and stubborn'),
    11: Chapter(size: 8, leastPasses: 3, title: 'room to work'),
    21: Chapter(size: 10, leastPasses: 4, title: 'ten across'),
    31: Chapter(size: 12, leastPasses: 5, title: 'the long lines'),
    46: Chapter(size: 15, leastPasses: 6, title: 'full size'),
    61: Chapter(size: 15, leastPasses: 7, title: 'no easy start'),
    81: Chapter(size: 15, leastPasses: 8, title: 'the deep end'),
  };

  /// Where puzzle [number] sits. Numbers start at one, because a book of
  /// puzzles that opens at zero is a book written by a programmer.
  static Chapter chapterOf(int number) {
    assert(number >= 1, 'puzzles are numbered from one');
    var found = _chapters[1]!;
    for (final entry in _chapters.entries) {
      if (entry.key <= number) found = entry.value;
    }
    return found;
  }

  /// Where in its chapter a puzzle is, counting from one.
  static int placeInChapter(int number) {
    var start = 1;
    for (final at in _chapters.keys) {
      if (at <= number) start = at;
    }
    return number - start + 1;
  }

  /// The puzzle at [number].
  ///
  /// Never null in practice: every chapter's difficulty has been shown to be
  /// reachable, and the maker searches six hundred pictures per seed. The test
  /// for this walks the first hundred puzzles rather than trusting it.
  static Puzzle at(int number, {Maker maker = const Maker()}) {
    final chapter = chapterOf(number);
    final puzzle = maker.make(
      seed: number,
      width: chapter.size,
      height: chapter.size,
      leastPasses: chapter.leastPasses,
    );
    if (puzzle == null) {
      throw StateError('no puzzle at $number, which should not be possible');
    }
    return puzzle;
  }
}
