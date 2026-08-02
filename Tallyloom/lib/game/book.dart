import 'maker.dart';

/// One stretch of the book: a size, and how hard its puzzles have to be.
class Chapter {
  const Chapter({
    required this.size,
    required this.leastPasses,
    required this.title,
    this.folds = true,
  });

  final int size;

  /// The floor on [Puzzle.passes], which is how many times the solver had to
  /// come back round the lines.
  final int leastPasses;

  /// What this stretch is called, for the line under the puzzle number.
  final String title;

  /// Whether its pictures are drawn symmetrical.
  ///
  /// They are, everywhere but the last chapter, because a folded picture looks
  /// like something and a scatter of blobs does not. The last chapter gives
  /// that up: symmetrical clues solve each other, and a puzzle that will not
  /// come out in under eight sweeps of the lines has to stop helping.
  final bool folds;
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

  /// Ten squares across is the biggest grid in the book, and the reason is
  /// the smallest phone still sold rather than anything about the puzzles.
  ///
  /// A row of clues needs room beside the grid, so the width a phone has to
  /// share out is the grid plus its deepest clue. On a 320 point screen that
  /// leaves 23 point squares at ten across, 19 at twelve and 15 at fifteen.
  /// Fifteen point squares are half a keyboard key: a thumb covers four of
  /// them. So the grids stop at ten and the climb carries on through the
  /// difficulty instead, which is the dial that was worth turning anyway.
  static const _chapters = <int, Chapter>{
    1: Chapter(size: 5, leastPasses: 1, title: 'the small ones'),
    6: Chapter(size: 5, leastPasses: 3, title: 'small and stubborn'),
    11: Chapter(size: 8, leastPasses: 3, title: 'room to work'),
    21: Chapter(size: 8, leastPasses: 4, title: 'eight across'),
    31: Chapter(size: 10, leastPasses: 4, title: 'ten across'),
    46: Chapter(size: 10, leastPasses: 5, title: 'the long lines'),
    61: Chapter(size: 10, leastPasses: 6, title: 'nothing for free'),
    81: Chapter(size: 10, leastPasses: 7, title: 'no easy start'),
    101: Chapter(size: 10, leastPasses: 8, title: 'the deep end', folds: false),
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
      folds: chapter.folds,
    );
    if (puzzle == null) {
      throw StateError('no puzzle at $number, which should not be possible');
    }
    return puzzle;
  }
}
