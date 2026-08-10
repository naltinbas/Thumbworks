/// A chase: the frame the type is locked into, and the line it should read.
///
/// One letter to a cell and one cell left empty, so that a letter beside the
/// empty cell can be slid into it. That is the only move there is.
class Chase {
  Chase({required this.name, required this.wide, required this.tall,
      required this.reading})
      : assert(reading.length == wide * tall - 1);

  final String name;
  final int wide;
  final int tall;

  /// The letters, in the order they should be read, with the empty cell after
  /// the last of them.
  final String reading;

  int get cells => wide * tall;
  int get sorts => reading.length;

  /// Where everything sits when the line reads right: the letters in order,
  /// and the empty cell last. A cell holds the number of the letter in it, or
  /// -1 for the empty one.
  List<int> get locked => [
        for (var sort = 0; sort < sorts; sort++) sort,
        -1,
      ];

  String letterOf(int sort) => reading[sort];

  int rowOf(int cell) => cell ~/ wide;
  int columnOf(int cell) => cell % wide;

  /// The cells a letter could be slid from into the empty one.
  List<int> beside(int empty) {
    final row = rowOf(empty);
    final column = columnOf(empty);
    return [
      if (column > 0) empty - 1,
      if (column < wide - 1) empty + 1,
      if (row > 0) empty - wide,
      if (row < tall - 1) empty + wide,
    ];
  }

  /// What the line reads as it stands, with a space for the empty cell.
  String reads(List<int> stands) => [
        for (final sort in stands) sort < 0 ? ' ' : reading[sort],
      ].join();

  bool isLocked(List<int> stands) {
    for (var cell = 0; cell < cells; cell++) {
      if (stands[cell] != locked[cell]) return false;
    }
    return true;
  }
}
