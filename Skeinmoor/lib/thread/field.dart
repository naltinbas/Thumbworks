import 'dart:typed_data';

/// The board a puzzle is set on: how big it is, and where the pairs of ends
/// are.
///
/// A cell is a number, counting across then down. Everything here is an array
/// of those rather than a grid of objects, because the solver walks it a few
/// hundred thousand times and a grid of objects is a few hundred thousand
/// pointer chases.
class Field {
  Field({
    required this.across,
    required this.down,
    required List<(int, int)> ends,
  }) : ends = List.unmodifiable(ends) {
    _steps = Int32List(across * down * 4);
    for (var at = 0; at < across * down; at++) {
      final row = at ~/ across;
      final column = at % across;
      const ways = [(0, -1), (1, 0), (0, 1), (-1, 0)];
      for (var i = 0; i < 4; i++) {
        final r = row + ways[i].$2;
        final c = column + ways[i].$1;
        _steps[at * 4 + i] =
            r < 0 || r >= down || c < 0 || c >= across ? -1 : r * across + c;
      }
    }
  }

  /// Reads a board out of a picture, a letter for each end of a thread and a
  /// dot for an empty cell.
  factory Field.picture(List<String> rows) {
    final across = rows.first.length;
    final firsts = <String, int>{};
    final pairs = <String, (int, int)>{};

    for (var row = 0; row < rows.length; row++) {
      for (var column = 0; column < across; column++) {
        final what = rows[row][column];
        if (what == '.') continue;
        final at = row * across + column;
        if (firsts.containsKey(what)) {
          pairs[what] = (firsts[what]!, at);
        } else {
          firsts[what] = at;
        }
      }
    }

    final letters = pairs.keys.toList()..sort();
    return Field(
      across: across,
      down: rows.length,
      ends: [for (final letter in letters) pairs[letter]!],
    );
  }

  final int across;
  final int down;

  /// The two ends of each thread, in order. The order is the order the
  /// threads are drawn in and the order the solver works through them.
  final List<(int, int)> ends;

  late final Int32List _steps;

  int get cells => across * down;
  int get threads => ends.length;

  int columnOf(int at) => at % across;
  int rowOf(int at) => at ~/ across;

  /// The cell one step away, or -1 off the edge.
  int beside(int at, int way) => _steps[at * 4 + way];

  /// Whether two cells touch.
  bool touching(int one, int other) {
    for (var way = 0; way < 4; way++) {
      if (_steps[one * 4 + way] == other) return true;
    }
    return false;
  }

  /// Which thread has an end on this cell, or -1.
  int endAt(int at) {
    for (var thread = 0; thread < ends.length; thread++) {
      if (ends[thread].$1 == at || ends[thread].$2 == at) return thread;
    }
    return -1;
  }
}
