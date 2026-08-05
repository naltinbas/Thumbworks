import 'dart:typed_data';

/// One jump: a peg leaves [from], the peg in [over] is taken, and the peg
/// lands in [to].
class Jump {
  const Jump(this.from, this.over, this.to);

  final int from;
  final int over;
  final int to;

  @override
  String toString() => '$from over $over to $to';

  @override
  bool operator ==(Object other) =>
      other is Jump && other.from == from && other.over == over && other.to == to;

  @override
  int get hashCode => Object.hash(from, over, to);
}

/// The shape of a board: which hollows there are, and every jump the shape
/// allows.
///
/// A hollow is a number, counting across then down. The jumps are worked out
/// once from the picture, because every part of the game asks for them —
/// the search millions of times.
class Field {
  Field(List<String> rows)
      : rows = List.unmodifiable(rows),
        wide = rows.first.length,
        deep = rows.length {
    final where = Int32List(wide * deep)..fillRange(0, wide * deep, -1);
    final rowOf = <int>[];
    final columnOf = <int>[];

    for (var row = 0; row < deep; row++) {
      for (var column = 0; column < wide; column++) {
        if (rows[row][column] == '#') continue;
        where[row * wide + column] = rowOf.length;
        rowOf.add(row);
        columnOf.add(column);
      }
    }
    _where = where;
    _rowOf = Int32List.fromList(rowOf);
    _columnOf = Int32List.fromList(columnOf);
    hollows = rowOf.length;

    // Two along a line, in each of the four directions. A jump and the same
    // jump backwards are two different jumps.
    final jumps = <Jump>[];
    for (var hollow = 0; hollow < hollows; hollow++) {
      final row = _rowOf[hollow];
      final column = _columnOf[hollow];
      for (final (dr, dc) in const [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
        final over = at(row + dr, column + dc);
        final to = at(row + dr * 2, column + dc * 2);
        if (over < 0 || to < 0) continue;
        jumps.add(Jump(hollow, over, to));
      }
    }
    this.jumps = List.unmodifiable(jumps);

    // The jumps that start, pass over or land on each hollow, so a move can
    // be looked up by where a finger touched rather than searched for.
    _fromHere = List.unmodifiable([
      for (var hollow = 0; hollow < hollows; hollow++)
        List<Jump>.unmodifiable(jumps.where((jump) => jump.from == hollow)),
    ]);
  }

  /// A picture with a dot for every hollow and a hash for a square that is
  /// not part of the board.
  final List<String> rows;

  final int wide;
  final int deep;

  /// How many hollows the board has.
  late final int hollows;

  /// Every jump the shape allows, whether or not there are pegs for it.
  late final List<Jump> jumps;

  late final Int32List _where;
  late final Int32List _rowOf;
  late final Int32List _columnOf;
  late final List<List<Jump>> _fromHere;

  int rowOf(int hollow) => _rowOf[hollow];
  int columnOf(int hollow) => _columnOf[hollow];

  /// Which hollow a square is, or -1 for a square that is not on the board.
  int at(int row, int column) {
    if (row < 0 || row >= deep || column < 0 || column >= wide) return -1;
    return _where[row * wide + column];
  }

  bool isHollow(int row, int column) => at(row, column) >= 0;

  List<Jump> jumpsFrom(int hollow) => _fromHere[hollow];

  /// Every peg in place, as a bag of pegs.
  int get full => hollows == 64 ? -1 : (1 << hollows) - 1;
}
