/// Where the mines are.
///
/// The player never sees one of these. Everything a player does goes through
/// [Play], which knows what has been opened; this knows what is underneath.
class Field {
  Field({
    required this.across,
    required this.down,
    required Set<int> mines,
    required this.opening,
  })  : mines = Set.unmodifiable(mines),
        assert(across > 0 && down > 0);

  final int across;
  final int down;

  /// Which cells hold a mine, as `row * across + column`.
  final Set<int> mines;

  /// The cell the board opens on.
  ///
  /// Every board starts with one square already open — the one the proof that
  /// it needs no guessing starts from. A first tap that can hit a mine is a
  /// coin toss, and moving the mines out of the way after the tap is a
  /// different board from the one that was tested.
  final int opening;

  int get cells => across * down;

  int columnOf(int at) => at % across;
  int rowOf(int at) => at ~/ across;

  bool holdsMine(int at) => mines.contains(at);

  /// The up-to-eight cells touching this one, diagonals included.
  List<int> around(int at) {
    final column = columnOf(at);
    final row = rowOf(at);
    final touching = <int>[];
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = row + dr;
        final c = column + dc;
        if (r < 0 || r >= down || c < 0 || c >= across) continue;
        touching.add(r * across + c);
      }
    }
    return touching;
  }

  /// How many mines touch this cell. The number a player reads.
  int countAt(int at) {
    var found = 0;
    for (final near in around(at)) {
      if (mines.contains(near)) found++;
    }
    return found;
  }

  /// Whether nothing at all touches this cell, which is what makes an opening
  /// open a region rather than a single square.
  bool isBlank(int at) => !holdsMine(at) && countAt(at) == 0;
}
