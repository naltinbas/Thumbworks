import 'dart:typed_data';

/// The arithmetic of the tray.
///
/// A board is a list of cells read row by row, each holding a tile
/// number, with nought for the gap. Home is the tiles in order and the
/// gap in the last cell. A shunt slides a tile beside the gap into it.
///
/// Everything the game claims comes from here two ways that share
/// nothing: a parity that never moves, and a walk of every board there
/// is. Neither is trusted without the other agreeing.
class Rules {
  Rules(this.rows, this.cols) {
    assert(cols.isOdd, 'the parity story below leans on an odd width');
    home = [for (var tile = 1; tile < cells; tile++) tile, 0];
    _walk();
  }

  final int rows;
  final int cols;

  int get cells => rows * cols;

  /// The board every tray wants to be.
  late final List<int> home;

  /// How many shunts each arrangement is from home, walked breadth
  /// first, indexed by rank. Unreachable arrangements hold 255.
  late final Uint8List distance;

  static const unreachable = 255;

  /// The farthest any reachable board is from home.
  late final int deepest;

  /// How many arrangements the walk reached.
  late final int reached;

  /// The rank of an arrangement: its place in the count of all
  /// orderings, nought for home's tiles in order. Lehmer, digit by
  /// digit.
  int rank(List<int> board) {
    var at = 0;
    for (var cell = 0; cell < cells; cell++) {
      var smaller = 0;
      for (var later = cell + 1; later < cells; later++) {
        if (board[later] < board[cell]) smaller++;
      }
      at = at * (cells - cell) + smaller;
    }
    return at;
  }

  int _factorial(int n) => n <= 1 ? 1 : n * _factorial(n - 1);

  /// The cells a gap there can swap with.
  List<int> besides(int gap) {
    final row = gap ~/ cols;
    final col = gap % cols;
    return [
      if (row > 0) gap - cols,
      if (row < rows - 1) gap + cols,
      if (col > 0) gap - 1,
      if (col < cols - 1) gap + 1,
    ];
  }

  /// One shunt: the tile at the cell slides into the gap. The board
  /// comes back unchanged if the cell does not touch the gap.
  List<int> shunted(List<int> board, int cell) {
    final gap = board.indexOf(0);
    if (!besides(gap).contains(cell)) return board;
    final out = [...board];
    out[gap] = out[cell];
    out[cell] = 0;
    return out;
  }

  /// The parity of the tiles read in order with the gap left out: how
  /// many pairs stand reversed, taken odd or even. A sideways shunt
  /// leaves the reading untouched; an up-or-down one slides a tile past
  /// cols minus one others, an even count on an odd-width tray. So no
  /// shunt ever moves this, and home is even: an odd board is dead.
  bool even(List<int> board) {
    final tiles = [
      for (final tile in board)
        if (tile != 0) tile,
    ];
    var reversed = 0;
    for (var one = 0; one < tiles.length; one++) {
      for (var other = one + 1; other < tiles.length; other++) {
        if (tiles[one] > tiles[other]) reversed++;
      }
    }
    return reversed.isEven;
  }

  /// The reversed pairs themselves, as tile numbers, for the words.
  List<(int, int)> reversedPairs(List<int> board) {
    final tiles = [
      for (final tile in board)
        if (tile != 0) tile,
    ];
    return [
      for (var one = 0; one < tiles.length; one++)
        for (var other = one + 1; other < tiles.length; other++)
          if (tiles[one] > tiles[other]) (tiles[one], tiles[other]),
    ];
  }

  void _walk() {
    distance = Uint8List(_factorial(cells))..fillRange(0, _factorial(cells), unreachable);
    distance[rank(home)] = 0;
    var edge = [home];
    var far = 0;
    var count = 1;
    while (edge.isNotEmpty) {
      final next = <List<int>>[];
      for (final board in edge) {
        final here = distance[rank(board)];
        final gap = board.indexOf(0);
        for (final cell in besides(gap)) {
          final there = shunted(board, cell);
          final at = rank(there);
          if (distance[at] != unreachable) continue;
          distance[at] = here + 1;
          far = here + 1;
          count++;
          next.add(there);
        }
      }
      edge = next;
    }
    deepest = far;
    reached = count;
  }

  /// How many shunts this board is from home, or null if no shunting
  /// brings it there.
  int? fewest(List<int> board) {
    final at = distance[rank(board)];
    return at == unreachable ? null : at;
  }

  bool solvable(List<int> board) => fewest(board) != null;

  /// A cell whose shunt steps one nearer home, or null.
  int? next(List<int> board) {
    final here = fewest(board);
    if (here == null || here == 0) return null;
    final gap = board.indexOf(0);
    for (final cell in besides(gap)) {
      if (fewest(shunted(board, cell)) == here - 1) return cell;
    }
    return null;
  }

  /// Every arrangement there is, reachable or not. Heavy: meant for the
  /// sweeps in the suite and the checker.
  Iterable<List<int>> allBoards() sync* {
    final tiles = [for (var tile = 0; tile < cells; tile++) tile];
    yield* _arranged(tiles, 0);
  }

  Iterable<List<int>> _arranged(List<int> tiles, int from) sync* {
    if (from == tiles.length) {
      yield [...tiles];
      return;
    }
    for (var at = from; at < tiles.length; at++) {
      var swap = tiles[from];
      tiles[from] = tiles[at];
      tiles[at] = swap;
      yield* _arranged(tiles, from + 1);
      swap = tiles[from];
      tiles[from] = tiles[at];
      tiles[at] = swap;
    }
  }
}
