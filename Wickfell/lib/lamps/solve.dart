import 'grid.dart';

/// What is known about turning a board off.
class Answer {
  const Answer({
    required this.canBeDone,
    required this.fewest,
    required this.presses,
    required this.ways,
  });

  /// Whether the board can be turned off at all. Some cannot: on a five by
  /// five, three boards in four are impossible, and a game that hands one of
  /// those over is a game that cannot be finished.
  final bool canBeDone;

  /// The fewest presses that turn it off, or -1 if nothing does.
  final int fewest;

  /// One set of presses of that size, in order of lamp — which is as good an
  /// order as any, because the order of presses makes no difference at all.
  final List<int> presses;

  /// How many different sets of presses turn it off, of any size.
  final int ways;
}

/// Works out how to turn a board off.
///
/// Not by searching. Pressing a lamp exclusive-ors the board with a fixed
/// number, and pressing it twice undoes it — so a set of presses is a choice
/// of yes or no for each lamp, and turning the board off means picking the
/// presses whose numbers exclusive-or to exactly what is lit. That is a set
/// of linear equations, one for each lamp, and every value is a nought or a
/// one.
///
/// So it is solved the way linear equations are solved: work down the lamps
/// putting the system into a triangle, then read the answer back. Whatever is
/// left over at the bottom is the null space — the sets of presses that
/// change nothing — and every solution is one solution plus one of those.
/// Trying all of them is what gives the fewest presses rather than merely
/// some.
class Sums {
  Sums(this.grid) {
    _reduce();
  }

  final Grid grid;

  /// The rows of the system, and which press each one is about.
  final _rows = <int>[];
  final _about = <int>[];

  /// The sets of presses that change nothing at all.
  final _nothings = <int>[];

  List<int> get nothings => List.unmodifiable(_nothings);

  /// How many independent sets of presses change nothing. Two on a five by
  /// five, which is why only one board in four can be turned off.
  int get spare => _nothings.length;

  void _reduce() {
    // The system, one column a press: which lamps that press changes, and
    // which press it was, carried along beside it.
    final columns = <int>[...grid.presses];
    final which = <int>[for (var at = 0; at < grid.lamps; at++) 1 << at];

    var row = 0;
    for (var lamp = 0; lamp < grid.lamps && row < columns.length; lamp++) {
      var pivot = -1;
      for (var i = row; i < columns.length; i++) {
        if (columns[i] >> lamp & 1 == 1) {
          pivot = i;
          break;
        }
      }
      if (pivot < 0) continue;

      final heldColumn = columns[row];
      final heldWhich = which[row];
      columns[row] = columns[pivot];
      which[row] = which[pivot];
      columns[pivot] = heldColumn;
      which[pivot] = heldWhich;

      for (var i = 0; i < columns.length; i++) {
        if (i == row) continue;
        if (columns[i] >> lamp & 1 == 1) {
          columns[i] ^= columns[row];
          which[i] ^= which[row];
        }
      }

      _rows.add(columns[row]);
      _about.add(which[row]);
      row++;
    }

    // Whatever is left changes nothing: a set of presses whose effect on the
    // board is zero.
    for (var i = row; i < columns.length; i++) {
      if (columns[i] == 0 && which[i] != 0) _nothings.add(which[i]);
    }
  }

  /// One set of presses that turns the board off, or null if there is none.
  int? _oneWay(int board) {
    var left = board;
    var presses = 0;
    for (var i = 0; i < _rows.length; i++) {
      final lamp = _lowestBit(_rows[i]);
      if (left >> lamp & 1 == 1) {
        left ^= _rows[i];
        presses ^= _about[i];
      }
    }
    return left == 0 ? presses : null;
  }

  /// Everything worth knowing about a board.
  Answer answer(int board) {
    final one = _oneWay(board);
    if (one == null) {
      return const Answer(
        canBeDone: false,
        fewest: -1,
        presses: [],
        ways: 0,
      );
    }

    // Every solution is this one plus a set of presses that changes nothing,
    // and there are only a handful of those — four on a five by five. So the
    // fewest is found by trying all of them rather than by searching.
    var best = one;
    var bestCount = _count(one);
    for (var pick = 1; pick < 1 << _nothings.length; pick++) {
      var also = one;
      for (var i = 0; i < _nothings.length; i++) {
        if (pick >> i & 1 == 1) also ^= _nothings[i];
      }
      final count = _count(also);
      if (count < bestCount) {
        best = also;
        bestCount = count;
      }
    }

    return Answer(
      canBeDone: true,
      fewest: bestCount,
      presses: [
        for (var at = 0; at < grid.lamps; at++)
          if (best >> at & 1 == 1) at,
      ],
      ways: 1 << _nothings.length,
    );
  }

  static int _lowestBit(int value) {
    var at = 0;
    var left = value;
    while (left & 1 == 0) {
      left >>= 1;
      at++;
    }
    return at;
  }

  static int _count(int value) {
    var found = 0;
    var left = value;
    while (left != 0) {
      found += left & 1;
      left >>= 1;
    }
    return found;
  }
}
