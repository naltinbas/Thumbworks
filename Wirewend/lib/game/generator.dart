import 'dart:math';

import 'grid.dart';

/// Makes boards that can be solved, by building a solved one and then turning
/// every cell at random.
///
/// The wires are grown as a spanning tree from the source, so every cell the
/// tree reaches is connected to the source by exactly one path. That is what
/// guarantees solvability without ever running a solver: the arrangement the
/// generator produced is itself an answer, and scrambling only turns cells,
/// which cannot change what is reachable from what.
class Generator {
  Generator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// A scrambled board of this size with roughly this share of cells used.
  ///
  /// [fill] is the share of the grid the wire tree grows into, between 0 and
  /// 1. Below about a third the board reads as scattered rather than as a
  /// puzzle, so it is clamped.
  Board generate({
    required int rows,
    required int cols,
    double fill = 0.85,
  }) {
    assert(rows >= 2 && cols >= 2, 'a board needs room for a source and a lamp');
    final solved = _grow(rows: rows, cols: cols, fill: fill.clamp(0.35, 1.0));

    // A scramble can leave the board already solved, which is a puzzle that
    // asks nothing. Try again rather than ship it, and give up after enough
    // attempts so a tiny board cannot spin forever.
    for (var attempt = 0; attempt < 40; attempt++) {
      final board = solved.scrambled(_random);
      if (!board.isSolved) return board;
    }
    return solved.scrambled(_random);
  }

  /// The solved arrangement: a spanning tree of wire with lamps at its leaves.
  Board _grow({required int rows, required int cols, required double fill}) {
    final total = rows * cols;
    final wanted = max(2, (total * fill).round());

    // Each cell's edges as the tree grows into it.
    final ends = List<Ends>.filled(total, Ends.none);
    final inTree = List<bool>.filled(total, false);

    final startRow = _random.nextInt(rows);
    final startCol = _random.nextInt(cols);
    final start = startRow * cols + startCol;
    inTree[start] = true;

    // Grow by repeatedly joining a cell next to the tree. Picking the cell at
    // random rather than always the newest gives branches rather than one
    // long snake, which is what makes the puzzle interesting to look at and
    // to solve.
    final frontier = <int>[start];
    var size = 1;
    while (size < wanted && frontier.isNotEmpty) {
      final pick = _random.nextInt(frontier.length);
      final index = frontier[pick];
      final row = index ~/ cols;
      final col = index % cols;

      final options = <(Ends, int)>[];
      for (final end in Ends.all) {
        final delta = step(end);
        final r = row + delta.row;
        final c = col + delta.col;
        if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
        final neighbour = r * cols + c;
        if (inTree[neighbour]) continue;
        options.add((end, neighbour));
      }

      if (options.isEmpty) {
        frontier.removeAt(pick);
        continue;
      }

      final (end, neighbour) = options[_random.nextInt(options.length)];
      ends[index] = ends[index] | end;
      ends[neighbour] = ends[neighbour] | opposite(end);
      inTree[neighbour] = true;
      frontier.add(neighbour);
      size++;
    }

    // A cell the tree reached through exactly one edge is a leaf, and a leaf
    // is where a lamp goes. The source keeps its own cell whatever its shape.
    final cells = <Cell>[];
    for (var i = 0; i < total; i++) {
      if (!inTree[i]) {
        cells.add(Cell(kind: CellKind.empty, ends: Ends.none));
        continue;
      }
      final kind = i == start
          ? CellKind.source
          : (ends[i].count == 1 ? CellKind.lamp : CellKind.wire);
      cells.add(Cell(kind: kind, ends: ends[i]));
    }

    final board = Board(rows: rows, cols: cols, cells: cells);

    // A tree with no leaf but the source is a board with nothing to light.
    // That only happens on a board too small to branch, so grow the smallest
    // useful thing instead of returning a puzzle that cannot be won.
    if (board.lampCount == 0) {
      return _grow(rows: rows, cols: cols, fill: 1.0);
    }
    return board;
  }
}
