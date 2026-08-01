import 'dart:math';

/// Which edges of a cell a piece of wire reaches.
///
/// Stored as four bits so a rotation is a bit rotation and a connection test
/// is an and. The order is north, east, south, west, which makes a quarter
/// turn clockwise a shift by one.
extension type const Ends(int bits) {
  static const north = Ends(1);
  static const east = Ends(2);
  static const south = Ends(4);
  static const west = Ends(8);
  static const none = Ends(0);

  /// The four in reading order, so a caller can walk them without knowing the
  /// bit layout.
  static const all = [north, east, south, west];

  bool has(Ends end) => bits & end.bits != 0;

  Ends operator |(Ends other) => Ends(bits | other.bits);

  /// A quarter turn clockwise: north becomes east, and west wraps to north.
  Ends get turned => Ends(((bits << 1) | (bits >> 3)) & 0xF);

  /// How many edges this reaches, which is what tells a dead end from a
  /// corner from a junction.
  int get count => bits.toRadixString(2).replaceAll('0', '').length;
}

/// The edge that faces this one from the neighbouring cell.
Ends opposite(Ends end) => switch (end) {
      Ends.north => Ends.south,
      Ends.east => Ends.west,
      Ends.south => Ends.north,
      Ends.west => Ends.east,
      _ => Ends.none,
    };

/// The step in row and column taken by leaving through this edge.
({int row, int col}) step(Ends end) => switch (end) {
      Ends.north => (row: -1, col: 0),
      Ends.east => (row: 0, col: 1),
      Ends.south => (row: 1, col: 0),
      Ends.west => (row: 0, col: -1),
      _ => (row: 0, col: 0),
    };

/// What a cell is for, as opposed to how it is shaped.
enum CellKind {
  /// Where the current comes from. Exactly one of these per board.
  source,

  /// A lamp. The board is solved when every one of these is lit.
  lamp,

  /// Wire, which carries current without being the point of anything.
  wire,

  /// A cell with no wire in it at all.
  empty,
}

/// One cell: what it is, which edges it reaches, and how far it has been
/// turned from the shape the generator gave it.
class Cell {
  Cell({required this.kind, required this.ends, this.turns = 0});

  final CellKind kind;

  /// The edges as the cell sits now, already turned.
  final Ends ends;

  /// Quarter turns applied since the board was made. Kept for the animation
  /// rather than for the logic, which only ever reads [ends].
  final int turns;

  Cell get turned => Cell(kind: kind, ends: ends.turned, turns: turns + 1);

  bool get isEmpty => kind == CellKind.empty;
}

/// A board, and the only thing that decides whether it is solved.
///
/// The board is immutable: turning a cell gives a new board. That keeps undo
/// and animation honest, and it means a test can hold a position and compare
/// it against what a move produced.
class Board {
  Board({required this.rows, required this.cols, required List<Cell> cells})
      : assert(cells.length == rows * cols, 'cell count must match the shape'),
        _cells = List.unmodifiable(cells);

  final int rows;
  final int cols;
  final List<Cell> _cells;

  Cell at(int row, int col) => _cells[row * cols + col];

  bool inside(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  /// The board with the cell at this position turned a quarter clockwise.
  Board turn(int row, int col) {
    final next = List<Cell>.from(_cells);
    next[row * cols + col] = at(row, col).turned;
    return Board(rows: rows, cols: cols, cells: next);
  }

  /// Every cell the current reaches from the source.
  ///
  /// Current crosses an edge only when both cells reach it, which is what
  /// makes a wire that points at a wall carry nothing. The walk is breadth
  /// first from the source, so it terminates whatever shape the wires make,
  /// including a loop.
  Set<int> get powered {
    final start = _cells.indexWhere((c) => c.kind == CellKind.source);
    if (start < 0) return const {};

    final seen = <int>{start};
    final queue = <int>[start];
    while (queue.isNotEmpty) {
      final index = queue.removeLast();
      final row = index ~/ cols;
      final col = index % cols;
      final cell = at(row, col);
      for (final end in Ends.all) {
        if (!cell.ends.has(end)) continue;
        final delta = step(end);
        final r = row + delta.row;
        final c = col + delta.col;
        if (!inside(r, c)) continue;
        if (!at(r, c).ends.has(opposite(end))) continue;
        final neighbour = r * cols + c;
        if (seen.add(neighbour)) queue.add(neighbour);
      }
    }
    return seen;
  }

  /// Whether every lamp is lit. A board with no lamps is not solved, because
  /// a board with nothing to light is not a puzzle.
  bool get isSolved {
    final lit = powered;
    var lamps = 0;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i].kind != CellKind.lamp) continue;
      lamps++;
      if (!lit.contains(i)) return false;
    }
    return lamps > 0;
  }

  int get lampCount =>
      _cells.where((c) => c.kind == CellKind.lamp).length;

  int get litLampCount {
    final lit = powered;
    var count = 0;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i].kind == CellKind.lamp && lit.contains(i)) count++;
    }
    return count;
  }

  /// The board with every cell turned a random number of times.
  ///
  /// Scrambling is how a solved board becomes a puzzle, and because a turn
  /// never changes what a cell is or how many edges it reaches, a scrambled
  /// board is always solvable: turning each cell back gets you here.
  Board scrambled(Random random) {
    var board = this;
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (at(row, col).isEmpty) continue;
        for (var i = random.nextInt(4); i > 0; i--) {
          board = board.turn(row, col);
        }
      }
    }
    return board;
  }
}
