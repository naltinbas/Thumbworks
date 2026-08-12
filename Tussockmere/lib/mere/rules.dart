/// The law of the mere.
///
/// The marsh is a rhombus of tussocks, every tussock touching six.
/// You step gold and link the west bank to the east; the mere grows
/// rushes and links the north to the south. One tussock a turn, and
/// a full marsh always carries exactly one crossing: never both,
/// never neither, checked on every filling there is. The house
/// plays the game solved to its end.
class Rules {
  Rules(this.size);

  final int size;

  final Map<int, int> _memo = {};

  /// The six neighbours of a tussock, kept inside the marsh.
  List<int> neighbours(int at) {
    final row = at ~/ size;
    final col = at % size;
    final out = <int>[];
    for (final (dr, dc) in const [
      (0, 1),
      (0, -1),
      (1, 0),
      (-1, 0),
      (-1, 1),
      (1, -1),
    ]) {
      final r = row + dr;
      final c = col + dc;
      if (r >= 0 && r < size && c >= 0 && c < size) {
        out.add(r * size + c);
      }
    }
    return out;
  }

  /// Whether a side has its crossing: gold (1) west to east, the
  /// mere (2) north to south.
  bool crosses(List<int> cells, int side) {
    final stack = <int>[];
    final seen = List<bool>.filled(size * size, false);
    for (var line = 0; line < size; line++) {
      final at = side == 1 ? line * size : line;
      if (cells[at] == side) {
        stack.add(at);
        seen[at] = true;
      }
    }
    while (stack.isNotEmpty) {
      final at = stack.removeLast();
      if (side == 1 ? at % size == size - 1 : at ~/ size == size - 1) {
        return true;
      }
      for (final next in neighbours(at)) {
        if (!seen[next] && cells[next] == side) {
          seen[next] = true;
          stack.add(next);
        }
      }
    }
    return false;
  }

  /// Who wins with [toMove] to step, both playing the marsh out
  /// perfectly. Solved once and remembered.
  int winner(List<int> cells, int toMove) {
    final key = _encode(cells) * 2 + (toMove - 1);
    final held = _memo[key];
    if (held != null) return held;
    int result;
    if (crosses(cells, 1)) {
      result = 1;
    } else if (crosses(cells, 2)) {
      result = 2;
    } else {
      result = 3 - toMove;
      for (var at = 0; at < size * size; at++) {
        if (cells[at] != 0) continue;
        cells[at] = toMove;
        final then = winner(cells, 3 - toMove);
        cells[at] = 0;
        if (then == toMove) {
          result = toMove;
          break;
        }
      }
    }
    _memo[key] = result;
    return result;
  }

  /// A winning step for [toMove] when one exists, else any open
  /// tussock; -1 on a full marsh.
  int bestStep(List<int> cells, int toMove) {
    var any = -1;
    for (var at = 0; at < size * size; at++) {
      if (cells[at] != 0) continue;
      if (any == -1) any = at;
      cells[at] = toMove;
      final then = winner(cells, 3 - toMove);
      cells[at] = 0;
      if (then == toMove) return at;
    }
    return any;
  }

  /// The openings that survive a perfect reply: stepped first by
  /// gold, gold still wins.
  List<int> strongOpenings() {
    final strong = <int>[];
    for (var at = 0; at < size * size; at++) {
      final cells = List<int>.filled(size * size, 0);
      cells[at] = 1;
      if (winner(cells, 2) == 1) strong.add(at);
    }
    return strong;
  }

  /// Whether every filling of the marsh carries exactly one
  /// crossing.
  bool everyFillingCarriesOne() {
    final total = size * size;
    for (var bits = 0; bits < (1 << total); bits++) {
      final cells = [
        for (var at = 0; at < total; at++)
          (bits >> at) & 1 == 1 ? 1 : 2,
      ];
      if (crosses(cells, 1) == crosses(cells, 2)) return false;
    }
    return true;
  }

  int _encode(List<int> cells) {
    var code = 0;
    for (var at = cells.length - 1; at >= 0; at--) {
      code = code * 3 + cells[at];
    }
    return code;
  }
}
