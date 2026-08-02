import 'picture.dart';

/// The numbers down the side and along the top of a puzzle.
///
/// A clue is the lengths of the runs of filled squares in its line, in order.
/// `[3, 1]` means three together, then at least one gap, then one, with any
/// amount of empty space before, between and after.
class Clues {
  Clues({required List<List<int>> rows, required List<List<int>> columns})
      : rows = List.unmodifiable(rows.map(List<int>.unmodifiable)),
        columns = List.unmodifiable(columns.map(List<int>.unmodifiable));

  /// The clues a picture gives rise to. This is the only way a puzzle is ever
  /// made: numbers are read off a picture, never invented, so a puzzle always
  /// has at least the answer it was made from.
  factory Clues.of(Picture picture) => Clues(
        rows: [
          for (var row = 0; row < picture.height; row++)
            Picture.runsIn(picture.row(row)),
        ],
        columns: [
          for (var col = 0; col < picture.width; col++)
            Picture.runsIn(picture.column(col)),
        ],
      );

  final List<List<int>> rows;
  final List<List<int>> columns;

  int get width => columns.length;
  int get height => rows.length;

  /// How many squares the clues say are filled, counted down the rows.
  int get filledCount => rows.fold(
        0,
        (sum, clue) => sum + clue.fold(0, (a, b) => a + b),
      );

  /// Whether the rows and the columns agree about how many squares are
  /// filled. They must, for clues read off a picture; this is here to catch a
  /// puzzle assembled by hand or loaded from somewhere that got it wrong.
  bool get isConsistent =>
      filledCount ==
      columns.fold(0, (sum, clue) => sum + clue.fold(0, (a, b) => a + b));

  /// The longest clue in a set, which is what the space beside the grid has to
  /// be big enough to hold.
  int get deepestRow => rows.fold(0, (most, clue) => clue.length > most ? clue.length : most);
  int get deepestColumn =>
      columns.fold(0, (most, clue) => clue.length > most ? clue.length : most);

  /// Whether a line is complete, given what is filled in it.
  ///
  /// Used to cross a clue off once the player has satisfied it, which is how
  /// a nonogram tells you where you are without telling you where you are
  /// wrong.
  static bool satisfied(List<int> clue, List<bool> line) {
    final runs = Picture.runsIn(line);
    if (runs.length != clue.length) return false;
    for (var i = 0; i < runs.length; i++) {
      if (runs[i] != clue[i]) return false;
    }
    return true;
  }
}
